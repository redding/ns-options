module NsOptions

  class Option

    class CoerceError < ::ArgumentError
      attr_reader :message, :backtrace
      def initialize(type_class, value, err)
        @backtrace = err.backtrace
        @message = "can't coerce `#{value.inspect}' to `#{type_class}':"\
                   " #{err.message}"
      end
    end

    def self.rules(rules)
      (rules || {}).tap do |r|
        r[:args] = (r[:args] ? [*r[:args]] : [])
      end
    end

    def self.args(*args)
      [ self.rules(args.last.kind_of?(::Hash) ? args.pop : {}),
        # if a nil type_class is given, just use Object
        # this makes the option accept any value with no type coercion
        (args[1] || Object),
        args[0].to_s
      ]
    end

    attr_accessor :name, :value, :type_class, :rules

    def initialize(*args)
      self.rules, self.type_class, self.name = self.class.args(*args)
      self.reset
    end

    # if reading a lazy_proc, call the proc and return its coerced return val
    # otherwise, just return the stored value
    def value
      if self.lazy_proc?(@value)
        self.coerce(@value.call)
      elsif @value.respond_to?(:returned_value)
        @value.returned_value
      else
        @value
      end
    end

    # if setting a lazy_proc, just store the proc off to be called when read
    # otherwise, coerce and store the value being set
    def value=(new_value)
      @value = self.lazy_proc?(new_value) ? new_value : self.coerce(new_value)
    end

    def reset
      self.value = self.rules[:default]
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

    def coerce(value)
      return value if (value.kind_of?(self.type_class)) || value.nil?

      begin
        if [ Integer, Float, String ].include?(self.type_class)
          # ruby type conversion, i.e. String(1)
          Object.send(self.type_class.to_s, value)
        elsif self.type_class == Symbol
          value.to_sym
        elsif self.type_class == Hash
          {}.merge(value)
        else
          self.type_class.new(value, *self.rules[:args])
        end
      rescue Exception => err
        raise CoerceError.new(self.type_class, value, err)
      end
    end

  end

end
