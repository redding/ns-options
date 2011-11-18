module NsOptions

  class Option
    autoload :Boolean, 'ns-options/option/boolean'

    attr_accessor :name, :value, :type_class, :rules

    def initialize(name, type_class = nil, rules = {})
      self.name = name.to_s
      self.type_class = self.usable_type_class(type_class)
      self.rules = rules
      self.rules[:args] = (self.rules[:args] ? [*self.rules[:args]] : [])
      self.value = rules[:default]
    end

    def value
      if self.type_class == NsOptions::Option::Boolean
        @value and @value.actual
      else
        @value
      end
    end

    def value=(new_value)
      @value = if (new_value.kind_of?(self.type_class)) || new_value.nil?
        new_value
      else
        self.coerce(new_value)
      end
    end

    def is_set?
      self.value.respond_to?(:is_set?) ? self.value.is_set? : !self.value.nil?
    end

    def required?
      !!self.rules[:required] || !!self.rules[:require]
    end

    def ==(other)
      [ :name, :type_class, :rules, :value ].inject(true) do |bool, attribute|
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
        self.type_class.new(new_value, *self.rules[:args])
      end
    end

    def usable_type_class(type_class)
      if type_class == Fixnum
        Integer
      elsif [ TrueClass, FalseClass ].include?(type_class)
        NsOptions::Option::Boolean
      elsif type_class == NilClass
        Object
      else
        (type_class || Object)
      end
    end

  end

end
