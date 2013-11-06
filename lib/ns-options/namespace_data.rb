require 'ns-options/options'
require 'ns-options/namespaces'

module NsOptions

  class NamespaceData

    attr_reader :ns, :option_type_class, :child_options, :child_namespaces

    def initialize(ns, option_type_class)
      @ns, @option_type_class = ns, option_type_class
      @child_namespaces       = NsOptions::Namespaces.new
      @child_options          = NsOptions::Options.new
    end

    # Recursively check if options that were defined as :required have been set.
    def required_set?
      @child_options.required_set? && @child_namespaces.required_set?
    end

    def set_option_type_class(value)
      @option_type_class = value
    end

    def has_option?(name);     !!@child_options[name];         end
    def get_option(name);      @child_options.get(name);       end
    def set_option(name, val); @child_options.set(name, val);  end
    def add_option(*args)
      name = args.first
      opt  = NsOptions::Option.new(*NsOptions::Option.args(args, @option_type_class))

      @child_namespaces.rm(name)
      @child_options.add(name, opt)
    end

    def has_namespace?(name);  !!@child_namespaces[name];      end
    def get_namespace(name);   @child_namespaces.get(name);    end
    def add_namespace(name, option_type_class=nil, &block)
      opt_type_class = option_type_class || @option_type_class
      ns = NsOptions::Namespace.new(name, opt_type_class, &block)

      @child_options.rm(name)
      @child_namespaces.add(name, ns)
    end

    # recursively build a hash representation of the namespace, using symbols
    # for the option/namespace name-keys
    def to_hash
      Hash.new.tap do |hash|
        @child_options.each do |name, opt|
          # this is meant to be a "value exporter", so always use distinct values
          # on the returned hash to prevent unintentional pass-by-ref shared objects
          hash[name.to_sym] = NsOptions.distinct_value(opt.value)
        end
        @child_namespaces.each{|name, value| hash[name.to_sym] = value.to_hash}
      end
    end

    # The opposite of #to_hash. Takes a hash representation of options and
    # namespaces and mass assigns option values.
    def apply(values=nil)
      (values || {}).each do |name, value|
        if has_namespace?(name)
          # recursively apply namespace values if hash given; ignore otherwise.
          get_namespace(name).apply(value) if value.kind_of?(Hash)
        else
          # this is meant as a "value importer", so always apply distinct values
          # to prevent unintentional pass-by-ref shared objects.
          # be sure to use the namespace's writer to write the option value
          @ns.send("#{name}=", NsOptions.distinct_value(value))
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
      set_option_type_class(other_ns_data.option_type_class)

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

    class DslMethod
      attr_reader :name, :data

      def initialize(meth, *args, &block)
        @method_string, @args, @block = meth.to_s, args, block
        @name = @method_string.gsub("=", "")
        @data = args.size == 1 ? args[0] : args
      end

      def writer?;   !!(@method_string =~ /=\Z/); end
      def reader?;   !self.writer?;               end
      def has_args?; !@args.empty?;               end
    end

    def ns_respond_to?(meth)
      dslm = DslMethod.new(meth)

      has_namespace?(dslm.name) || # namespace reader
      has_option?(dslm.name)    || # option reader
      dslm.writer?              || # dynamic option writer
      false
    end

    def ns_method_missing(meth, *args, &block)
      dslm = DslMethod.new(meth, *args, &block)

      if is_namespace_reader?(dslm)
        get_namespace(dslm.name).define(&block)
      elsif is_option_reader?(dslm)
        get_option(dslm.name)
      elsif is_option_writer?(dslm)
        add_option(dslm.name) unless has_option?(dslm.name)
        set_option(dslm.name, dslm.data)
      else # namespace writer or unknown
        raise NoMethodError.new("undefined method `#{meth}' for #{@ns.inspect}")
      end
    end

    private

    def is_namespace_reader?(dsl_method)
      has_namespace?(dsl_method.name)  && !dsl_method.has_args?
    end

    def is_option_reader?(dsl_method)
      has_option?(dsl_method.name)     && !dsl_method.has_args?
    end

    def is_option_writer?(dsl_method)
      !has_namespace?(dsl_method.name) && dsl_method.has_args?
    end

  end
end
