module App
  include NsOptions::Configurable
  configurable(:settings, "settings:app") do
    option :root,   Pathname, :require => true
    option :stage,            :require => true
    option :logger, Logger,   :require => true

    namespace :sub do
      option :run_commands, NsOptions::Option::Boolean
    end
  end
end
