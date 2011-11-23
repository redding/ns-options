module NsOptions
  module Helper

    class Advisor
      attr_accessor :namespace

      def initialize(namespace)
        self.namespace = namespace
      end

      def is_this_ok?(kind, name, from)
        display = kind == :option ? "option" : "sub-namespace"
        if self.bad_methods.include?(name.to_sym)
          message = self.bad_method_message(display, name)
          exception = NsOptions::Errors::InvalidName.new(message, from)
          raise(exception)
        elsif self.is_already_defined?(kind, name)
          puts self.duplicate_message(display, name)
        elsif self.not_recommended_methods.include?(name.to_sym)
          puts self.not_recommended_method_message(display, name)
        else
          return false
        end
        puts "From: #{from.first}"
        true
      end

      def is_this_option_ok?(name, from)
        self.is_this_ok?(:option, name, from)
      end

      def is_this_namespace_ok?(name, from)
        self.is_this_ok?(:namespace, name, from)
      end

      def is_already_defined?(kind, name)
        case(kind)
        when :option
          self.namespace.options.is_defined?(name)
        when :namespace
          self.namespace.options.is_namespace_defined?(name)
        end
      end

      def bad_methods
        @bad_methods ||= [ :option, :namespace, :define ]
      end

      def not_recommended_methods
        @not_recommended_methods ||= (self.namespace_instance_methods.reject do |method|
          self.bad_methods.include?(method)
        end).map(&:to_sym)
      end

      protected

      def bad_method_message(kind, name)
        [ "The #{kind} '#{name}' overwrites a namespace method that NsOptions depends on.",
          "Please choose a different name for your #{kind}."
        ].join(" ")
      end
      def duplicate_message(kind, name)
        [ "WARNING! The #{kind} '#{name}' has been defined more than once.",
          "It's likely that it will not behave as expected."
        ].join(" ")
      end
      def not_recommended_method_message(kind, name)
        [ "WARNING! The #{kind} '#{name}' overwrites a namespace method.",
          "This will limit some of the functionality of NsOptions."
        ].join(" ")
      end


      def namespace_instance_methods
        NsOptions::Namespace.instance_methods(false)
      end

    end

  end
end
