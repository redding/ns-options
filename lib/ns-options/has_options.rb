module NsOptions

  module HasOptions
    class << self

      def included(klass)
        klass.class_eval do
          extend NsOptions::HasOptions::DSL
        end
      end

    end

    module DSL

      # This is the main DSL method for creating a namespace of options for your class/module. This
      # will define a class method for both classes and modules and an additional instance method
      # for classes. The namespace is then created and returned by calling the class method version.
      # For classes, the instance method will build an entirely new namespace from the class level
      # namespace. This is so when you define options at the class level:
      #
      # class Something
      #   include NsOptions
      #   options(:settings) do
      #      option :root
      #   end
      # end
      #
      # the namespaces at the instance level still get all the defined options, but are completely
      # separate objects from the class and other instances. Modules only deal with a single
      # namespace at the module level.
      def options(name, key = nil, &block)
        key ||= name.to_s
        method_definitions = <<-CLASS_METHOD

          def self.#{name}(&block)
            @#{name} ||= NsOptions::Namespace.new('#{key}', &block)
          end

        CLASS_METHOD
        if self.kind_of?(Class)
          method_definitions += <<-INSTANCE_METHOD

            def #{name}(&block)
              unless @#{name}
                @#{name} = NsOptions::Namespace.new('#{key}', &block)
                @#{name}.options.build_from(self.class.#{name}.options)
              end
              @#{name}
            end

          INSTANCE_METHOD
        end
        self.class_eval(method_definitions)
        self.send(name, &block)
      end

    end

  end

end
