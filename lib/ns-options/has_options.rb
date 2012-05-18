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

      # This is the main DSL method for creating a namespace of options for your
      # class/module. This will define a class method for both classes and
      # modules and an additional instance method for classes. The namespace is
      # then created and returned by calling the class method version.  For
      # classes, the instance method will build an entirely new namespace from
      # the class level namespace. This is so when you define options at the
      # class level:
      #
      # class Something
      #   include NsOptions
      #   options(:settings) do
      #      option :root
      #   end
      # end
      #
      # the namespaces at the instance level still get all the defined options,
      # but are completely separate objects from the class and other instances.
      # Modules only deal with a single namespace at the module level.

      # The options method takes three args:
      # * `name` : what to name the defined methods for accessing the namespace
      # * `key`  : (optional) what to key the created namespace objects with
      #            - defaults to `name`
      #            - useful if persisting namespaces into some key-value store
      # * `block`: (optional) a predefined set of nested options and namespaces

      def options(name, key = nil, &block)
        NsOptions::Helper.advisor.is_this_namespace_ok?(name, caller)
        NsOptions::Helper.define_root_namespace_methods(self, name, key)
        self.send(name, &block)
      end
      alias_method :opts, :options

    end

  end

end
