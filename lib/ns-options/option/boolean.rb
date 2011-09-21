module NsOptions
  class Option

    class Boolean
      attr_accessor :actual

      def initialize(value)
        self.actual = self.convert(value)
      end

      protected

      def convert(value)
        if [ 0, '0', false, 'false' ].include?(value)
          false
        elsif value
          true
        end
      end
    end

  end
end
