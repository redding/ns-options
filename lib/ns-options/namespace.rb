require 'ns-options/namespace_data'
require 'ns-options/namespace_advisor'

module NsOptions

  class Namespace

    attr_reader :__name__, :__data__

    def initialize(name, option_type_class=nil, &block)
      @__name__ = name
      @__data__ = NamespaceData.new(self, option_type_class || Object)
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

    def option_type_class(*args)
      return @__data__.option_type_class if args.empty?
      @__data__.set_option_type_class(*args)
    end
    alias_method :opt_type_class, :option_type_class

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

    def respond_to?(meth)
      @__data__.ns_respond_to?(meth) || super
    end

    def method_missing(meth, *args, &block)
      @__data__.ns_method_missing(meth, *args, &block)
    rescue StandardError => exception
      exception.set_backtrace(caller)
      raise exception
    end

    def ==(other_ns)
      if other_ns.kind_of? Namespace
        self.to_hash == other_ns.to_hash
      else
        super
      end
    end

    def inspect(*args)
      inspect_details = to_hash.inspect rescue "error getting inspect details"
      "#<#{self.class}:#{'0x%x' % (self.object_id << 1)}:#{@__name__} #{inspect_details}>"
    end

  end

end
