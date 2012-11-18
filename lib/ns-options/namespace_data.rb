require 'ns-options/options'
require 'ns-options/namespaces'

module NsOptions

  class NamespaceData

    attr_reader :ns, :child_options, :child_namespaces

    def initialize(ns)
      @ns = ns
      @child_namespaces = NsOptions::Namespaces.new
      @child_options    = NsOptions::Options.new
    end

    # Recursively check if options that were defined as :required have been set.
    def required_set?
      @child_options.required_set? && @child_namespaces.required_set?
    end

    def has_option?(name);     !!@child_options[name];         end
    def get_option(name);      @child_options.get(name);       end
    def set_option(name, val); @child_options.set(name, val);  end
    def add_option(*args);     @child_options.add(*args);      end

    def has_namespace?(name);  !!@child_namespaces[name];      end
    def get_namespace(name);   @child_namespaces.get(name);    end
    def add_namespace(name, *args, &block)
      @child_namespaces.add(name, *args, &block)
    end

    # recursively build a hash representation of the namespace, using symbols
    # for the option/namespace name-keys
    def to_hash
      Hash.new.tap do |hash|
        @child_options.each{|name, opt| hash[name.to_sym] = opt.value}
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
          # be sure to use the namespace's writer to write the option value
          @ns.send("#{name}=", value)
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

    def ns_method_missing(bt, meth, *args, &block)
      dslm = DslMethod.new(meth, *args, &block)

      if is_namespace_reader?(dslm)
        get_namespace(dslm.name).define(&block)
      elsif is_option_reader?(dslm)
        get_option(dslm.name)
      elsif is_option_writer?(dslm)
        # TODO: remove same-named opt/ns when adding the other with same name
        add_option(dslm.name) unless has_option?(dslm.name)
        begin
          set_option(dslm.name, dslm.data)
        rescue NsOptions::Option::CoerceError
          error! bt, err # reraise this exception with a sane backtrace
        end
      else
        # raise a no meth err with a sane backtrace
        error! bt, NoMethodError.new("undefined method `#{meth}' for #{@ns.inspect}")
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

    def error!(backtrace, exception)
      exception.set_backtrace(backtrace); raise exception
    end

  end
end
