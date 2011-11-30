module NsOptions

  module Helper
    autoload :Advisor, 'ns-options/helper/advisor'

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

  end

end
