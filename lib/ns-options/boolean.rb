module NsOptions
  class Boolean

    attr_accessor :actual

    def initialize(value)
      self.actual = value
    end

    def actual=(new_value)
      @actual = self.convert(new_value)
    end

    def ==(other_boolean)
      if other_boolean.kind_of?(Boolean)
        self.actual == other_boolean.actual
      else
        self.actual == other_boolean
      end
    end

    def returned_value
      self.actual
    end

    protected

    def convert(value)
      if [ nil, 0, '0', false, 'false', 'f', 'F' ].include?(value)
        false
      elsif value
        true
      end
    end

  end
end
