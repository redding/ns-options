module NsOptions

  module Configurable
    class << self

      def included(klass)
        klass.class_eval do
          extend NsOptions::Configurable::DSL
        end
      end

    end


    module DSL

      def configurable(method_name, group_name, &block)
        self.class_eval <<-DEFINE_METHOD

          def #{method_name}
            @#{method_name} ||= self.class.#{method_name}.dup
          end

          def self.#{method_name}(&block)
            unless @#{method_name}
              @#{method_name} = NsOptions::Namespace.new(#{group_name.inspect})
            end
            @#{method_name}.configure(&block)
          end

        DEFINE_METHOD
        self.send(method_name, &block)
      end

    end

  end

end
