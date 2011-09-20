module NsOptions

  class Option
    autoload :Boolean, 'ns-options/option/boolean'
    
    attr_accessor :name, :value, :type_class, :options

    def initialize(name, type_class, options = {})
      self.name = name.to_s
      self.type_class = self.usable_type_class(type_class)
      self.options = options
      self.value = nil
    end

    def key
      self.name.to_sym
    end

    def value=(new_value)
      @value = if (new_value.class == self.type_class) || new_value.nil?
        new_value
      else
        self.coerce(new_value)
      end
    end

    def ==(other)
      [ :name, :type_class, :options, :value ].inject(true) do |bool, attribute|
        bool && (self.send(attribute) == other.send(attribute))
      end
    end

    protected

    def coerce(new_value)
      if [ Integer, Float, String ].include?(self.type_class)
        # ruby type conversion, i.e. String(1)
        Object.send(self.type_class.to_s.to_sym, new_value)
      elsif self.type_class == Hash
        {}.merge(new_value)
      else
        self.type_class.new(new_value)
      end
    end

    def usable_type_class(type_class)
      if type_class == Fixnum
        Integer
      elsif [ TrueClass, FalseClass ].include?(type_class)
        NsOptions::Option::Boolean
      else
        (type_class || String)
      end
    end

  end

end
