module NsOptions

  class Options < Hash
    attr_accessor :name, :parent, :children
    alias :namespaces :children

    def initialize(name, parent = nil)
      self.name = name
      self.parent = parent
      self.children = NsOptions::Namespaces.new
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
    alias :del :remove

    def get(name)
      option = self[name]
      if option && !option.value.nil?
        option.value
      elsif self.defaults
        self.parent_options.get(name)
      end
    end

    def set(name, new_value)
      self[name].value = new_value
      self[name]
    end

    def is_defined?(name)
      !!self[name] || !!(self.parent_options && self.parent_options.is_defined?(name))
    end

    def parent_options
      self.parent and self.parent.options
    end

  end

end
