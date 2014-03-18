require "georgia_heroku/version"
require "rails"

module GeorgiaHeroku
  class DeployTask < Rails::Railtie
    rake_tasks do
      Dir[File.join(File.dirname(__FILE__),'tasks/*.rake')].each { |f| load f }
    end
  end
end
