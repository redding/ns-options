require 'ns-options/namespace_data'
require 'ns-options/namespace_advisor'

module NsOptions

  class Namespace

    attr_reader :__data__

    def initialize(name, &block)
      @__data__ = NamespaceData.new(self, name)
      @__data__.define(&block)
    end

    def option(name, *args)
      NamespaceAdvisor.new(@__data__, name, 'an option').run($stdout, caller)
      @__data__.add_option(name, *args)
    end
    alias_method :opt, :option

    def namespace(name, &block)
      NamespaceAdvisor.new(@__data__, name, 'a namespace').run($stdout, caller)
      @__data__.add_namespace(name, &block)
    end
    alias_method :ns, :namespace

    def respond_to?(meth)
      # TODO: respond_to dynamic writers
      data_name = meth.to_s.gsub("=", "")
      has_option?(data_name) || has_namespace?(data_name) || super
    end

    def method_missing(meth, *args, &block)
      data_name = meth.to_s.gsub("=", "")
      value = args.size == 1 ? args[0] : args
      if has_option?(data_name)
        # write and/or read a known child option
        @__data__.set_option(data_name, value) if !args.empty?
        @__data__.get_option(data_name)
      elsif has_namespace?(data_name)
        # read a known child namespace
        @__data__.get_namespace(data_name).define(&block)
      elsif !args.empty?
        # add and set a new child option (dynamic writer)
        @__data__.add_option(data_name)
        @__data__.set_option(data_name, value)
        @__data__.get_option(data_name)
      else
        super
      end
    end

    def has_option?(name);    @__data__.has_option?(name);    end
    def has_namespace?(name); @__data__.has_namespace?(name); end
    def required_set?;        @__data__.required_set?;        end
    alias_method :valid?, :required_set?

    def define(*args, &block);  @__data__.define(*args, &block);         end
    def build_from(other_ns);   @__data__.build_from(other_ns.__data__); end
    def apply(*args, &block);   @__data__.apply(*args, &block);          end
    def to_hash(*args, &block); @__data__.to_hash(*args, &block);        end
    def each(*args, &block);    @__data__.each(*args, &block);           end

    def ==(other_ns)
      if other_ns.kind_of? Namespace
        self.to_hash == other_ns.to_hash
      else
        super
      end
    end

    def inspect(*args)
      "#<#{self.class}:#{'0x%x' % (self.object_id << 1)}:#{@__data__.name} #{to_hash.inspect}>"
    end

  end

end
