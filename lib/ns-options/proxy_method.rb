require 'ns-options/namespace'
require 'ns-options/option'

module NsOptions
  class ProxyMethod

    # This class handles defining proxy class methods for classes or modules
    # and an additional instance method for classes.

    def initialize(define_on, name, kind)
      @define_on, @name, @kind = define_on, name, kind
      @meth_extension_mixin = Module.new
      @meth_extension_mixin.class_eval proxy_meth_code
    end

    def define_on_class?
      !!@define_on.kind_of?(::Class)
    end

    def define(io=nil, from_caller=nil)
      validate(io || $stdout, from_caller || caller)

      # covers defining the class-level method on Modules or Classes
      @define_on.send :extend, @meth_extension_mixin

      # covers defining the instance-level method on Classes
      @define_on.send :include, @meth_extension_mixin if define_on_class?
    end

    def validate(io, from_caller)
      return true unless not_recommended_meth_names.include?(@name.to_sym)

      io.puts "WARNING: Defining #{@kind} with the name `#{@name}' overwrites a"\
              " method NsOptions::Proxy depends on and may cause it to not"\
              " behave correctly."
      io.puts from_caller.first
      false
    end

    private

    # TODO: inherited hook to build_from and apply on the subclass root meth
    def proxy_meth_code
      "def #{@name}(*args, &block); __proxy_options__.#{@name}; end"
    end

    def not_recommended_meth_names
      [ :option, :opt, :namespace, :ns,
        :define, :inspect, :method_missing, :respond_to?,
        :apply, :to_hash, :each, :required_set?, :valid?,
      ]
    end

  end
end
