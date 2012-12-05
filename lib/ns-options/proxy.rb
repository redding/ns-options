require 'ns-options'
require 'ns-options/proxy_method'

module NsOptions::Proxy

  # Mix this in to any module or class to make it proxy a namespace
  # this means you can interact with the module/class/class-instance as
  # if it were a namespace object itself.

  NAMESPACE = "__proxy_options__"

  def self.included(receiver)
    NsOptions::RootMethods.new(receiver, NAMESPACE).define
    receiver.class_eval { extend  ProxyMethods }

    if receiver.kind_of?(Class)

      receiver.class_eval { include ProxyMethods                 }
      receiver.class_eval { extend  ClassReceiverExtendMethods   }
      receiver.class_eval { include ClassReceiverIncludeMethods  }

    else # Module

      receiver.class_eval { extend  ModuleReceiverExtendMethods  }

    end
  end

  module ClassReceiverExtendMethods

    # This hook copies the proxy definition to any subclasses
    def inherited(subclass)
      subclass.__proxy_options__.build_from(self.__proxy_options__)
    end

    def inspect(*args, &block)
      "#<#{super()}:#{__proxy_options__.__name__} #{__proxy_options__.to_hash.inspect}>"
    end

  end

  module ClassReceiverIncludeMethods

    # default initializer method
    def initialize(configs=nil)
      self.apply(configs || {})
    end

    # equality method override for class-instance proxies
    def ==(other_proxy_instance)
      __proxy_options__ == other_proxy_instance.__proxy_options__
    end

    def inspect(*args, &block)
      "#<#{self.class.name}:#{'0x%x' % (self.object_id << 1)}:#{__proxy_options__.__name__} #{__proxy_options__.to_hash.inspect}>"
    end

  end

  module ModuleReceiverExtendMethods

    # default initializer method
    def new(configs=nil)
      self.apply(configs || {})
    end

    def inspect(*args, &block)
      "#<#{super()}:#{__proxy_options__.__name__} #{__proxy_options__.to_hash.inspect}>"
    end

  end

  module ProxyMethods

    # pass thru namespace methods to the proxied NAMESPACE handler

    def option(name, *args, &block)
      __proxy_options__.option(name, *args, &block)
      NsOptions::ProxyMethod.new(self, name, 'an option').define($stdout, caller)
    end
    alias_method :opt, :option

    def namespace(name, *args, &block)
      __proxy_options__.namespace(name, *args, &block)
      NsOptions::ProxyMethod.new(self, name, 'a namespace').define($stdout, caller)
    end
    alias_method :ns, :namespace

    def option_type_class(*args, &block)
      __proxy_options__.option_type_class(*args, &block)
    end
    alias_method :opt_type_class, :option_type_class

    def has_option?(*args, &block);    __proxy_options__.has_option?(*args, &block);    end
    def has_namespace?(*args, &block); __proxy_options__.has_namespace?(*args, &block); end
    def required_set?(*args, &block);  __proxy_options__.required_set?(*args, &block);    end
    def valid?(*args, &block);         __proxy_options__.valid?(*args, &block);           end

    def apply(*args, &block);   __proxy_options__.apply(*args, &block);   end
    def to_hash(*args, &block); __proxy_options__.to_hash(*args, &block); end
    def each(*args, &block);    __proxy_options__.each(*args, &block);    end
    def define(*args, &block);  __proxy_options__.define(*args, &block);  end

    def inspect(*args, &block)
      "#<#{self.class}:#{'0x%x' % (self.object_id << 1)}:#{__proxy_options__.__name__} #{__proxy_options__.to_hash.inspect}>"
    end

    # for everything else, send to the proxied NAMESPACE handler
    # at this point it really just enables dynamic options writers

    def method_missing(meth, *args, &block)
      if (po = __proxy_options__) && po.respond_to?(meth.to_s)
        po.send(meth.to_s, *args, &block)
      else
        super
      end
    end

    def respond_to?(*args)
      if (po = self.__proxy_options__) && po.respond_to?(args.first.to_s)
        true
      else
        super
      end
    end

  end

end
