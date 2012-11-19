require 'ns-options/namespace'

module NsOptions
  class RootMethods

    # This class handles defining a root namespace class method for classes
    # or modules and an additional instance method for classes. For classes, the
    # instance method will build an entirely new namespace, distinct from  the
    # class level namespace but with an identical definition

    def initialize(define_on, name)
      @define_on, @name     = define_on, name
      @class_meth_extension = Module.new
      @instance_meth_mixin  = Module.new
    end

    def define_on_class?
      !!@define_on.kind_of?(::Class)
    end

    def define(io=nil, from_caller=nil)
      validate(io || $stdout, from_caller || caller)

      # covers defining the class-level method on Modules or Classes
      @class_meth_extension.class_eval class_meth_extension_code
      @define_on.send :extend, @class_meth_extension

      if define_on_class?
        # covers defining the instance-level method on Classes
        @instance_meth_mixin.class_eval instance_meth_mixin_code
        @define_on.send :include, @instance_meth_mixin
      end
    end

    def validate(io, from_caller)
      return true unless [:options, :opts, :namespace, :ns].include?(@name.to_sym)

      io.puts "WARNING: Defining an option namespace with the name `#{@name}'"\
              " overwrites a method NsOptions depends on.  You won't be able to"\
              " define any additional option namespaces using the `#{@name}'"\
              " method."
      io.puts from_caller.first
      false
    end

    private

    # TODO: be able to call with block over and over
    def class_meth_extension_code
      %{
        def #{@name}(*args, &block)
          unless @#{@name}
            @#{@name} = NsOptions::Namespace.new('#{@name}', *args, &block)
            if respond_to?('superclass') && superclass &&
               superclass.respond_to?('#{@name}') &&
               superclass.#{@name}.kind_of?(NsOptions::Namespace)
              @#{@name}.build_from(superclass.#{@name})
            end
          end
          @#{@name}
        end
      }
    end

    # TODO: be able to call with block over and over
    def instance_meth_mixin_code
      %{
        def #{@name}(*args, &block)
          unless @#{@name}
            @#{@name} = NsOptions::Namespace.new('#{@name}', *args, &block)
            @#{@name}.build_from(self.class.#{@name})
          end
          @#{@name}
        end
      }
    end

  end
end
