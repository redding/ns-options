require 'ns-options/namespace'

module NsOptions
  class Namespaces < Hash

    # for hash with indifferent access behavior
    def [](name);         super(name.to_sym);        end
    def []=(name, value); super(name.to_sym, value); end

    def add(name, &block)
      self[name] = NsOptions::Namespace.new(name, &block)
    end

    def get(name); self[name]; end

    def required_set?
      self.values.inject(true) do |bool, ns|
        bool && ns.required_set?
      end
    end

  end
end
