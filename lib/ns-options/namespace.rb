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
      namespace = self.options.namespaces.add(name, self, &block)

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

    def method_missing(method, *args, &block)
      if args.empty? && self.respond_to?(method)
        self.option(method)
        self.send(method)
      elsif !args.empty?
        value = args.size == 1 ? args[0] : args
        option_name = method.to_s.gsub("=", "")
        self.option(option_name, value.class)
        self.send("#{option_name}=", value)
      else
        super
      end
    end

    def respond_to?(method)
      super or self.options.is_defined?(method.to_s.gsub("=", ""))
    end

  end

end
