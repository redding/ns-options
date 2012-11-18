require 'ns-options/namespace_data'
require 'ns-options/namespace_advisor'

module NsOptions

  class Namespace

    attr_reader :__data__

    def initialize(name, handling=nil, &block)
      @__data__ = NamespaceData.new(self, name, handling)
      @__data__.define(&block)
    end

    def option(name, *args)
      NamespaceAdvisor.new(@__data__, name, 'an option').run($stdout, caller)
      @__data__.add_option(name, *args)
    end
    alias_method :opt, :option

    def namespace(name, *args, &block)
      NamespaceAdvisor.new(@__data__, name, 'a namespace').run($stdout, caller)
      @__data__.add_namespace(name, *args, &block)
    end
    alias_method :ns, :namespace

    def respond_to?(meth)
      @__data__.ns_respond_to?(meth) || super
    end

    def method_missing(meth, *args, &block)
      @__data__.ns_method_missing(caller, meth, *args, &block)
    end

    def has_option?(name);    @__data__.has_option?(name);    end
    def has_namespace?(name); @__data__.has_namespace?(name); end
    def required_set?;        @__data__.required_set?;        end
    alias_method :valid?, :required_set?

    def define(*args, &block);  @__data__.define(*args, &block);         end
    def build_from(other_ns);   @__data__.build_from(other_ns.__data__); end
    def reset(*args, &block);   @__data__.reset(*args, &block);          end
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
