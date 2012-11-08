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
      name = meth.to_s.gsub("=", "")
      writer = !!(meth.to_s =~ /=\Z/)

      has_namespace?(name) ||              # namespace reader
      (has_option?(name) && !writer) ||    # option reader
      (writer && !value_option?(name)) ||  # option writer
      super
    end

    def method_missing(meth, *args, &block)
      data_name = meth.to_s.gsub("=", "")
      writer_meth = !!(meth.to_s =~ /=\Z/)
      data_to_write = !args.empty?
      value = args.size == 1 ? args[0] : args

      if has_namespace?(data_name)
        # TODO: remove same named opt/ns when adding the other with same name
        # read a known child namespace
        @__data__.get_namespace(data_name).define(&block)
      elsif has_option?(data_name) && !data_to_write
        # read the defined option
        @__data__.get_option(data_name)
      elsif data_to_write && !value_option?(data_name)
        # define the option if needed (dynamic writer)
        @__data__.add_option(data_name) unless has_option?(data_name)
        # write the defined option
        @__data__.set_option(data_name, value)
      elsif data_to_write && value_option?(data_name) && !writer_meth
        # trying to write a :value option using the reader w/ args
        err = ArgumentError.new("wrong number of arguments (#{args.size} for 0)")
        err.set_backtrace(caller)
        raise err
      else
        # trying to write a :value option using the writer
        # or other unknown method
        err = NoMethodError.new("undefined method `#{meth}' for #{self.inspect}")
        err.set_backtrace(caller)
        raise err
      end
    end

    def has_option?(name);    @__data__.has_option?(name);    end
    def value_option?(name);  @__data__.value_option?(name);  end
    def has_namespace?(name); @__data__.has_namespace?(name); end
    def required_set?;        @__data__.required_set?;        end
    alias_method :valid?, :required_set?

    def define(*args, &block);  @__data__.define(*args, &block);         end
    def build_from(other_ns);   @__data__.build_from(other_ns.__data__); end
    def reset(*args, &block);   @__data__.reset(*args, &block);          end
    def to_hash(*args, &block); @__data__.to_hash(*args, &block);        end
    def each(*args, &block);    @__data__.each(*args, &block);           end

    # The opposite of #to_hash. Takes a hash representation of options and
    # namespaces and mass assigns option values.
    def apply(values=nil)
      (values || {}).each do |name, value|
        if has_namespace?(name) && value.kind_of?(Hash)
          # recursively apply namespace values
          @__data__.get_namespace(name).apply(value)
        else
          # write the option value
          self.send("#{name}=", value)
        end
      end
    end

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
