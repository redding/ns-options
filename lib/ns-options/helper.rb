module NsOptions

  module Helper
    module_function

    # Common method for creating a new namespace
    def new_namespace(key, parent = nil, &block)
      namespace = NsOptions::Namespace.new(key, parent)
      namespace.define(&block)
    end

    # Common method for creating a new child namespace, using the owner's class's options as the
    # parent.
    def new_child_namespace(owner, name, &block)
      parent = owner.class.send(name)
      method = "#{name}_key"
      key = if owner.respond_to?(method)
        owner.send(method)
      else
        "#{owner.class.to_s.split('::').last.downcase}_#{owner.object_id}"
      end
      namespace = parent.namespace(name, key)
      namespace.define(&block)
    end

    def fetch_and_define_option(namespace, option_name)
      option = namespace.options.fetch(option_name)
      namespace.option(option.name, option.type_class, option.rules)
      option
    end

  end

end
