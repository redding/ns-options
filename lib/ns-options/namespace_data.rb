require 'ns-options/options'
require 'ns-options/namespaces'

module NsOptions
  class NamespaceData

    attr_reader :ns, :name, :child_options, :child_namespaces

    def initialize(ns, name)
      @ns   = ns
      @name = name
      @child_options    = NsOptions::Options.new
      @child_namespaces = NsOptions::Namespaces.new
    end

    # Recursively check if options that were defined as :required have been set.
    def required_set?
      @child_options.required_set? && @child_namespaces.required_set?
    end

    def has_option?(name);     !!@child_options[name];         end
    def get_option(name);      @child_options.get(name);       end
    def set_option(name, val); @child_options.set(name, val);  end
    def add_option(*args);     @child_options.add(*args);      end

    def has_namespace?(name);        !!@child_namespaces[name];           end
    def get_namespace(name);         @child_namespaces.get(name);         end
    def add_namespace(name, &block); @child_namespaces.add(name, &block); end

    # recursively build a hash representation of the namespace, using symbols
    # for the option/namespace name-keys
    def to_hash
      Hash.new.tap do |hash|
        @child_options.each{|name, opt| hash[name.to_sym] = opt.value}
        @child_namespaces.each{|name, value| hash[name.to_sym] = value.to_hash}
      end
    end

    # The opposite of #to_hash. Takes a hash representation of options and namespaces and mass
    # assigns option values.
    def apply(values = {})
      values.each do |name, value|
        if has_option?(name)
          # set a pre-defined option value
          set_option(name, value)
        elsif has_namespace?(name) && value.kind_of?(Hash)
          # recursively set namespace values
          get_namespace(name).apply(value)
        elsif !has_option?(name)
          # dynamically add a non-pre-defined option value
          add_option(name)
          set_option(name, value)
        end
      end
    end

    # allow for iterating over the key/values of a namespace
    # this uses #to_hash so you won't get option/namespace objs for the values
    def each
      to_hash.each{|k,v| yield k,v if block_given? }
    end

    # define the parent ns using the given block
    def define(&block)
      if block && block.arity > 0
        block.call @ns
      elsif block
        @ns.instance_eval(&block)
      end
      @ns
    end

    def build_from(other_ns_data)
      other_ns_data.child_options.each do |name, opt|
        add_option(name, opt.type_class, opt.rules)
      end
      other_ns_data.child_namespaces.each do |name, ns|
        new_ns = add_namespace(name)
        new_ns.build_from(ns)
      end
    end

    def reset
      child_options.each {|name, opt| opt.reset}
      child_namespaces.each {|name, ns| ns.reset}
    end

  end
end
