module NsOptions

  class Namespaces < Hash

    def [](name)
      super(name.to_sym)
    end
    def []=(name, value)
      super(name.to_sym, value)
    end

    def add(name, parent = nil, &block)
      namespace = NsOptions::Namespace.new(name, parent)
      namespace.configure(&block)
      self[name] = namespace
    end

    def get(name)
      self[name]
    end

  end

end
