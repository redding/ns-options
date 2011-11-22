module NsOptions

  class Options < Hash
    attr_accessor :key, :parent, :namespaces

    def initialize(key, parent = nil)
      self.key = key.to_s
      self.parent = parent
      self.namespaces = NsOptions::Namespaces.new
    end

    def [](name)
      super(name.to_sym)
    end
    def []=(name, value)
      super(name.to_sym, value)
    end

    def add(*args)
      options = args.last.kind_of?(Hash) ? args.pop : {}
      option = NsOptions::Option.new(args[0], args[1], options)
      self[option.name] = option
    end

    def del(name)
      self[name] = nil
    end
    alias :remove :del

    def get(name)
      option = self[name]
      option and option.value
    end

    def set(name, new_value)
      self[name].value = new_value
      self[name]
    end

    def is_defined?(name)
      !!self[name]
    end

    def required_set?
      self.values.reject{|option| !option.required? }.inject(true) do |bool, option|
        bool && option.is_set?
      end
    end
    
    def add_namespace(name, key, parent = nil, &block)
      self.namespaces.add(name, key, parent, &block)
    end

    def build_from(options)
      options.each do |key, option|
        self.add(option.name, option.type_class, option.rules)
      end
    end

  end

end
