module NsOptions
  class Option

    class Boolean
      attr_accessor :actual

      def initialize(value)
        self.actual = value
      end

      def actual=(new_value)
        @actual = self.convert(new_value)
      end

      protected

      def convert(value)
        if [ nil, 0, '0', false, 'false' ].include?(value)
          false
        elsif value
          true
        end
      end
    end

  end
end
