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

      def configurable(name, key = nil, &block)
        key ||= name.to_s
        self.class_eval <<-DEFINE_METHOD

          def #{name}(&block)
            @#{name} ||= NsOptions::Helper.new_child_namespace(self, '#{name}', &block)
          end

          def self.#{name}(&block)
            @#{name} ||= NsOptions::Helper.new_namespace('#{key}', &block)
          end

        DEFINE_METHOD
        self.send(name, &block)
      end

    end

  end

end
