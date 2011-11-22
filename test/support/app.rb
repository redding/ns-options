require 'ns-options/option/boolean'

module App

  # mixin on just the top-level NsOptions variant
  include NsOptions

  options(:settings, "settings:app") do
    option :root,   Pathname
    option :stage
    option :logger, Logger

    namespace :sub do
      option :run_commands, NsOptions::Option::Boolean
    end
  end
end
