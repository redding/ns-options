require 'ns-options/namespace'

module NsOptions
  class Namespaces

    def initialize
      @hash = Hash.new
    end

    # for hash with indifferent access behavior
    def [](name);         @hash[name.to_s];         end
    def []=(name, value); @hash[name.to_s] = value; end

    def keys(*args, &block);   @hash.keys(*args, &block);   end
    def each(*args, &block);   @hash.each(*args, &block);   end
    def empty?(*args, &block); @hash.empty?(*args, &block); end

    def add(name, &block)
      self[name] = NsOptions::Namespace.new(name, &block)
    end

    def get(name); self[name]; end

    def required_set?
      are_all_these_namespaces_set? @hash.values
    end

    private

    def are_all_these_namespaces_set?(namespaces)
      namespaces.inject(true) {|bool, ns| bool && ns.required_set?}
    end

  end
end
