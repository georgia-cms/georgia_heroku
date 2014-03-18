require 'bundler'

module Georgia
  module Heroku
    module Generators
      class InstallGenerator < ::Rails::Generators::Base
        source_root File.expand_path('../templates', __FILE__)

        desc "Prepare Georgia CMS to be hosted on Heroku"

        def ensure_heroku_toolbet_installed
        end

        def heroku_gems
          gem_group :production do
            gem 'heroku-deflater'
            gem 'rails_12factor'
          end
        end

        def heroku_environment_config
          gsub_file('config/environments/production.rb',
            "config.serve_static_assets = false",
            "# Enable Rails's static asset server for Heroku\nconfig.serve_static_assets = true")
          application "config.assets.initialize_on_precompile = false" if Rails::VERSION::MAJOR == 3 and Rails::VERSION::MINOR >= 1
        end

        def cache_config
          gem 'dalli'
          gem 'kgio'
          gem 'rack-cache'
          gem 'memcachier'
          run "heroku addons:add memcachier"
          inject_into_file 'config/environments/production.rb', after: "Application.configure do" do <<-'RUBY'

            # Set static assets cache header. rack-cache will cache those.
            config.static_cache_control = "public, max-age=31536000"

            config.cache_store = :dalli_store

            client = Dalli::Client.new(ENV["MEMCACHIER_SERVERS"],
                               :value_max_bytes => 10485760,
                               :expires_in => 86400)

            # Configure rack-cache for using memcachier
            config.action_dispatch.rack_cache = {
              :metastore    => client,
              :entitystore  => client
            }
          RUBY
          end
        end

        def unicorn
          gem 'unicorn', group: :production
          copy_file "config/unicorn.rb"
          copy_file "Procfile"
        end

        def add_build_pack
          run "heroku config:add BUILDPACK_URL=https://github.com/ndbroadbent/heroku-buildpack-turbo-sprockets.git"
        end

        def deploy
          rake "georgia:heroku:deploy"
        end

        def bonsai_config
          gem 'tire'
          run "heroku addons:add bonsai"
          copy_file "config/initializers/bonsai.rb"
          run "heroku run rake environment tire:import CLASS=Georgia::Page FORCE=true"
          run "heroku run rake environment tire:import CLASS=Ckeditor::Asset FORCE=true"
          run "heroku run rake environment tire:import CLASS=Ckeditor::Picture FORCE=true"
        end

        def sendgrid_config
          run "heroku addons:add sendgrid"
          inject_into_file 'config/environments/production.rb', after: "Application.configure do" do <<-'RUBY'

            # Send emails via sendgrid
            config.action_mailer.smtp_settings = {
              :address        => 'smtp.sendgrid.net',
              :port           => '587',
              :authentication => :plain,
              :user_name      => ENV['SENDGRID_USERNAME'],
              :password       => ENV['SENDGRID_PASSWORD'],
              :domain         => 'heroku.com',
              :enable_starttls_auto => true
            }
          RUBY
          end
        end

        def cloudinary_config
          gem 'cloudinary'
          run "heroku addons:add cloudinary"
        end

        def deploy
          rake "georgia:heroku:deploy"
        end

        def show_readme
          readme "README"
        end

      end
    end
  end
end