module NsOptions

  class Namespaces < Hash

    def [](name)
      super(name.to_sym)
    end
    def []=(name, value)
      super(name.to_sym, value)
    end

    def add(name, key, parent = nil, &block)
      self[name] = NsOptions::Namespace.new(key, parent, &block)
    end

    def get(name)
      self[name]
    end

  end

end
