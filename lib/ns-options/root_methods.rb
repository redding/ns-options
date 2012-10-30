require 'ns-options/namespace'

module NsOptions
  class RootMethods

    # This class handles defining a root namespace class method for classes
    # or modules and an additional instance method for classes. For classes, the
    # instance method will build an entirely new namespace, distinct from  the
    # class level namespace but with an identical definition

    def initialize(define_on, name)
      @define_on = define_on
      @name = name
      @class_meth_extension = Module.new
      @instance_meth_mixin = Module.new
    end

    def define_on_class?
      !!@define_on.kind_of?(::Class)
    end

    def define
      # covers defining the class-level method on Modules or Classes
      @class_meth_extension.class_eval class_meth_extension_code
      @define_on.extend @class_meth_extension

      if define_on_class?
        # covers defining the instance-level method on Classes
        @instance_meth_mixin.class_eval instance_meth_mixin_code
        @define_on.send :include, @instance_meth_mixin
      end
    end

    private

    # TODO: inherited hook to build_from and apply on the subclass root meth
    def class_meth_extension_code
      %{
        def #{@name}(&block)
          @#{@name} ||= NsOptions::Namespace.new('#{@name}', &block)
        end
      }
    end

    def instance_meth_mixin_code
      %{
        def #{@name}(&block)
          unless @#{@name}
            @#{@name} = NsOptions::Namespace.new('#{@name}', &block)
            @#{@name}.build_from(self.class.#{@name})
          end
          @#{@name}
        end
      }
    end

  end
end
