require 'ns-options'
require 'ns-options/boolean'
require 'logger'

module App

  # mixin on just the top-level NsOptions variant
  include NsOptions

  options(:settings) do
    option :root,   Pathname
    option :stage
    option :logger, Logger
    option :self_stage, :default => Proc.new { self.stage }

    namespace :sub do
      option :run_commands, NsOptions::Boolean
    end
  end
end
