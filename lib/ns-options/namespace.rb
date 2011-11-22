module NsOptions

  class Namespace
    attr_accessor :options, :metaclass

    def initialize(key, parent = nil)
      self.metaclass = (class << self; self; end)
      self.options = NsOptions::Options.new(key, parent)
    end

    def required_set?
      self.options.required_set?
    end
    alias :valid? :required_set?

    # Define an option for this namespace. Add the option to the namespace's options collection
    # and then define accessors for the option. With the following:
    #
    # namespace.option(:root, String, { :some_option => true })
    #
    # you will get accessors for root:
    #
    # namespace.root = "something"      # set's the root option to 'something'
    # namespace.root                    # => "something"
    # namespace.root("something else")  # set's the root option to `something-else`
    #
    # The defined option is returned as well.
    def option(*args)
      option = self.options.add(*args)

      self.metaclass.class_eval <<-DEFINE_METHOD

        def #{option.name}(*args)
          if !args.empty?
            self.send("#{option.name}=", *args)
          else
            self.options.get(:#{option.name})
          end
        end

        def #{option.name}=(*args)
          value = args.size == 1 ? args.first : args
          self.options.set(:#{option.name}, value)
        end

      DEFINE_METHOD

      option
    end

    # Define a namespace under this namespace. Firstly, a new key is constructured from this current
    # namespace's key and the name for the new namespace. The namespace is then added to the
    # options collection. Finally a reader method is defined for accessing the namespace. With the
    # following:
    #
    # parent_namespace.namespace(:specific) do
    #   option :root
    # end
    #
    # you will get a reader for the namespace:
    #
    # parent_namespace.specific                     # => returns the namespace
    # parent_namespace.specific.root = "something"  # => options are accessed in the same way
    #
    # The defined namespaces is returned as well.
    def namespace(name, key = nil, &block)
      key = "#{self.options.key}:#{(key || name)}"
      namespace = self.options.namespaces.add(name, key, self, &block)

      self.metaclass.class_eval <<-DEFINE_METHOD

        def #{name}(&block)
          namespace = self.options.namespaces.get("#{name}")
          namespace.define(&block) if block
          namespace
        end

      DEFINE_METHOD

      namespace
    end

    def apply(option_values = {})
      option_values.each do |name, value|
        namespace = self.options.namespaces[name]
        if self.options[name] || !namespace
          self.send("#{name}=", value)
        elsif namespace && value.kind_of?(Hash)
          namespace.apply(value)
        end
      end
    end

    # return a hash representation of the namespace
    # use symbols for the hash
    def to_hash
      Hash.new.tap do |out|
        self.options.each do |name, opt|
          out[name.to_sym] = opt.value
        end
        self.options.namespaces.each do |name, value|
          out[name.to_sym] = value.to_hash
        end
      end
    end

    # allow for iterating over the key/values of a namespace
    # this uses #to_hash so you won't get option/namespace objs for the values
    def each
      self.to_hash.each { |k,v| yield k,v if block_given? }
    end

    # The define method is provided for convenience and commonization. The internal system
    # uses it to commonly use a block with a namespace. The method can be used externally when
    # a namespace is created separately from where options are added/set on it. For example:
    #
    # parent_namespace.namespace(:specific)
    #
    # parent_namespace.specific.define do
    #   option :root
    # end
    #
    # Will define a new namespace under the parent namespace and then will later on add options to
    # it.
    def define(&block)
      if block && block.arity > 0
        yield self
      elsif block
        self.instance_eval(&block)
      end
      self
    end

    # There are a number of cases we want to watch for:
    # 1. A reader of a 'known' option. This case is for an option that's been defined for an
    #    ancestor of this namespace but not directly for this namespace. In this case we fetch
    #    the options definition and use it to define the option directly for this namespace.
    # 2. A writer of a 'known' option. This case is similar to the above, but instead we are
    #    wanting to write a value. We need to fetch the option definition, define it and then
    #    we write the option as we normally would.
    # 3. A dynamic writer. The option is not 'known' to the namespace, so we use the value and it's
    #    class to define the option for this namespace. Then we just use the writer as we normally
    #    would.
    def method_missing(method, *args, &block)
      option_name = method.to_s.gsub("=", "")
      value = args.size == 1 ? args[0] : args
      if args.empty? && self.respond_to?(option_name)
        option = NsOptions::Helper.fetch_and_define_option(self, option_name)
        self.send(option.name)
      elsif !args.empty? && self.respond_to?(option_name)
        option = NsOptions::Helper.fetch_and_define_option(self, option_name)
        self.send("#{option.name}=", value)
      elsif !args.empty?
        option = self.option(option_name)
        self.send("#{option.name}=", value)
      else
        super
      end
    end

    def respond_to?(method)
      super || self.options.is_defined?(method.to_s.gsub("=", ""))
    end

    def inspect(*args)
      "#<#{self.class}:#{'0x%x' % (self.object_id << 1)}:#{self.options.key} #{self.to_hash.inspect}>"
    end

  end

end
