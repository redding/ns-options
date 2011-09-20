module NsOptions
  class Option

    class Boolean
      attr_accessor :actual

      def initialize(value)
        self.actual = self.convert(value)
      end
      
      def ==(other)
        self.actual == other
      end
      
      def method_missing(method, *args, &block)
        self.actual.send(method, *args, &block)
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
