require 'ns-options/helper/advisor'

module NsOptions

  module Helper

    module_function

    def find_and_define_namespace(namespace, name)
      sub_namespace = namespace.options.get_namespace(name)
      self.define_namespace_methods(namespace, name)
      sub_namespace
    end

    def define_namespace_methods(namespace, name)
      namespace.metaclass.class_eval <<-DEFINE_METHOD

        def #{name}(&block)
          namespace = self.options.namespaces.get("#{name}")
          namespace.define(&block) if block
          namespace
        end

      DEFINE_METHOD
    end

    def find_and_define_option(namespace, option_name)
      option = namespace.options[option_name]
      self.define_option_methods(namespace, option)
      option
    end

    def define_option_methods(namespace, option)
      namespace.metaclass.class_eval <<-DEFINE_METHOD

        def #{option.name}(*args)
          if !args.empty?
            self.send("#{option.name}=", *args)
          else
            self.options.get(:#{option.name})
          end
        end

        def #{option.name}=(*args)
          value = args.size == 1 ? args.first : args
          self.options.set(:#{option.name}, value)
        end

      DEFINE_METHOD
    end

    def advisor(namespace=nil)
      NsOptions::Helper::Advisor.new(namespace)
    end

    def define_root_namespace_methods(define_on, name, key=nil)
      key ||= name.to_s

      # covers defining on Modules and at the class-level of Classes
      method_definitions = <<-CLASS_METHOD

        def self.#{name}(&block)
          @#{name} ||= NsOptions::Namespace.new('#{key}', &block)
        end

      CLASS_METHOD

      if define_on.kind_of?(Class)
        # covers defining at the instance-level of Classes
        method_definitions += <<-INSTANCE_METHOD

          def #{name}(&block)
            unless @#{name}
              @#{name} = NsOptions::Namespace.new('#{key}', &block)
              @#{name}.options.build_from(self.class.#{name}.options, @#{name})
            end
            @#{name}
          end

        INSTANCE_METHOD
      end
      define_on.class_eval(method_definitions)
    end

  end

end
