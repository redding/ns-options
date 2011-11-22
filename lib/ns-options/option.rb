module NsOptions

  class Option
    attr_accessor :name, :value, :type_class, :rules

    def initialize(name, type_class, rules={})
      self.name = name.to_s

      # if a nil type_class is given, just use Object
      # this makes the option accept any value with no type coercion
      self.type_class = (type_class || Object)

      self.rules = rules
      self.rules[:args] = (self.rules[:args] ? [*self.rules[:args]] : [])
      self.value = rules[:default]
    end

    # if reading a lazy_proc, call the proc and return its coerced return val
    # otherwise, just return the stored value
    def value
      self.lazy_proc?(@value) ? self.coerce(@value.call) : @value
    end

    # if setting a lazy_proc, just store the proc off to be called when read
    # otherwise, coerce and store the value being set
    def value=(new_value)
      @value = self.lazy_proc?(new_value) ? new_value : self.coerce(new_value)
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

    # a value is considered to by a lazy eval proc if it some kind of a of
    # Proc and the option it is being set on is not explicitly defined as some
    # kind of Proc
    # The allows you to set option values that should't be evaluated until they
    # are being read
    def lazy_proc?(value)
      value.kind_of?(::Proc) && !self.type_class.ancestors.include?(::Proc)
    end

    def coerce(new_value)
      return new_value if (new_value.kind_of?(self.type_class)) || new_value.nil?

      if [ Integer, Float, String ].include?(self.type_class)
        # ruby type conversion, i.e. String(1)
        Object.send(self.type_class.to_s.to_sym, new_value)
      elsif self.type_class == Symbol
        new_value.to_sym
      elsif self.type_class == Hash
        {}.merge(new_value)
      else
        self.type_class.new(new_value, *self.rules[:args])
      end
    end

  end

end
