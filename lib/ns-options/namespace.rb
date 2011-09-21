module NsOptions

  class Namespace
    attr_accessor :options, :metaclass

    INVALID_KEYS = [ :options, :metaclass, :option, :namespace, :configure, :method_missing,
      :respond_to ]

    def initialize(name, parent = nil)
      self.metaclass = (class << self; self; end)
      self.options = NsOptions::Options.new(name, parent)
    end

    def option(*args)
      if INVALID_KEYS.include?(args[0].to_sym)
        raise(ArgumentError, "An option named '#{args[0]}' cannot be created.")
      end
      option = self.options.add(*args)

      # define reader/writer for option.name
      self.metaclass.class_eval <<-DEFINE_METHOD

        def #{option.name}(*args)
          if !args.empty?
            self.send("#{option.name}=", *args)
          else
            self.options.get(#{option.key.inspect})
          end
        end

        def #{option.name}=(*args)
          value = args.size == 1 ? args.first : args
          self.options.set(#{option.key.inspect}, value)
        end

      DEFINE_METHOD

      option
    end

    def namespace(name, &block)
      if INVALID_KEYS.include?(name.to_sym)
        raise(ArgumentError, "A namespace named '#{args[0]}' cannot be created.")
      end
      key = "#{self.options.key}:#{name}"
      namespace = self.options.namespaces.add(name, key, self, &block)

      self.metaclass.class_eval <<-DEFINE_METHOD

        def #{name}(&block)
          namespace = self.options.namespaces.get(#{name.to_sym.inspect})
          namespace.configure(&block) if block
          namespace
        end

      DEFINE_METHOD

      namespace
    end

    def configure(&block)
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
        self.option(option_name, value.class)
        self.send("#{option.name}=", value)
      else
        super
      end
    end

    def respond_to?(method)
      super || self.options.is_defined?(method.to_s.gsub("=", ""))
    end

  end

end
