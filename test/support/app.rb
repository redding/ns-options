module App
  include NsOptions::Configurable
  configurable(:settings, "settings:app") do
    option :root,   Pathname
    option :stage
    option :logger, Logger

    namespace :sub do
      option :run_commands, NsOptions::Option::Boolean
    end
  end
end
