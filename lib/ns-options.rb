require "ns-options/version"

module NsOptions
  autoload :Configurable,   'ns-options/configurable'
  autoload :Namespace,      'ns-options/namespace'
  autoload :Namespaces,     'ns-options/namespaces'
  autoload :Option,         'ns-options/option'
  autoload :Options,        'ns-options/options'
end

# module I
#   module Config
#     include NsOptions::Configurable
#     include I::Config::Exposure
#     configurable :settings, 'i-config'
#     option :stage,         I::Config::Stage,   :require => true
#     option :app_key,                           :require => true
#     option :root,          Pathname
#     option :logger,        I::Config::Logger
#     option :hostname
#     option :run_callbacks, I::Config::Boolean
#     option :domain,        I::Config::Domain
#   end
# end
