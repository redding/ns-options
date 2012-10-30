require 'ns-options/root_methods'
require 'ns-options/proxy'
require 'ns-options/helper'

module NsOptions

  def self.included(receiver)
    receiver.class_eval { extend NsOptions::DSL }
  end

  module DSL

    # This is the main DSL method for creating a namespace of options for your
    # class/module. This will define a class method for classes/modules and
    # an additional instance method for classes.

    def options(name, &block)
      NsOptions::Helper.advisor.is_this_namespace_ok?(name, caller)
      NsOptions::RootMethods.new(self, name).define
      self.send(name, &block)
    end
    alias_method :opts,      :options
    alias_method :namespace, :options
    alias_method :ns,        :options

  end

end
