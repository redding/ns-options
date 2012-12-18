require 'ns-options/root_methods'
require 'ns-options/proxy'
require 'ns-options/struct'

module NsOptions

  def self.included(receiver)
    receiver.class_eval { extend NsOptions::DSL }
  end

  def self.distinct_value(value)
    begin
      value.clone
    rescue TypeError
      value
    end
  end

  module DSL

    # This is the main DSL method for creating a namespace of options for your
    # class/module. This will define a class method for classes/modules and
    # an additional instance method for classes.

    def options(name, *args, &block)
      NsOptions::RootMethods.new(self, name).define($stdout, caller)
      self.send(name, *args, &block)
    end
    alias_method :opts,      :options
    alias_method :namespace, :options
    alias_method :ns,        :options

  end

end
