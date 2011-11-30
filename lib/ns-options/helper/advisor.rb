module NsOptions
  module Helper

    class Advisor
      attr_accessor :namespace

      def initialize(namespace)
        self.namespace = namespace
      end

      # root namespace advisor

      def is_this_namespace_ok?(name, from = nil)
        if [:options].include?(name.to_sym)
          puts self.not_recommended_method_message('namespace', name)
        else
          return true
        end
        puts "From: #{(from || caller).first}"
        false
      end

      # sub-namespace / namespace-option advisors

      def is_this_sub_namespace_ok?(name, from = nil)
        self.is_this_ok?(:'sub-namespace', name, (from || caller))
      end

      def is_this_option_ok?(name, from = nil)
        self.is_this_ok?(:option, name, (from || caller))
      end

      # helper methods

      def is_this_ok?(kind, name, from)
        display = kind.to_s
        if self.bad_methods.include?(name.to_sym)
          message = self.bad_method_message(display, name)
          exception = NsOptions::Errors::InvalidName.new(message, from)
          raise(exception)
        elsif self.is_already_defined?(name)
          puts self.duplicate_message(name)
        elsif self.not_recommended_methods.include?(name.to_sym)
          puts self.not_recommended_method_message(display, name)
        else
          return true
        end
        puts "From: #{from.first}"
        false
      end

      def is_already_defined?(name)
        self.namespace.options.is_defined?(name) ||
        self.namespace.options.is_namespace_defined?(name)
      end

      def bad_methods
        @bad_methods ||= [ :option, :namespace, :define, :options ]
      end

      def not_recommended_methods
        @not_recommended_methods ||= NsOptions::Namespace.instance_methods(false).map(&:to_sym)
      end

      def bad_method_message(kind, name)
        [ "The #{kind} '#{name}' overwrites a namespace method that NsOptions depends on.",
          "Please choose a different name for your #{kind}."
        ].join(" ")
      end

      def duplicate_message(name)
        [ "WARNING! '#{name}' has already been defined and will be overwritten.",
          "It's likely that it will not behave as expected."
        ].join(" ")
      end

      def not_recommended_method_message(kind, name)
        [ "WARNING! The #{kind} '#{name}' overwrites a method NsOptions depends on.",
          "This will limit some of the functionality of NsOptions."
        ].join(" ")
      end

    end

  end
end
