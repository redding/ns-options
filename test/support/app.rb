module App
  include NsOptions::HasOptions
  options(:settings, "settings:app") do
    option :root,   Pathname
    option :stage
    option :logger, Logger

    namespace :sub do
      option :run_commands, NsOptions::Option::Boolean
    end
  end
end
