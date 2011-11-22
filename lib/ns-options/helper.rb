module NsOptions

  module Helper
    module_function

    # This method is a commonization of code used by a namespaces method_missing method. Essentially
    # if the case arises that a namespace has an option defined (i.e. namespace.options[name] is
    # not nil), then when you try to access it through a reader on the namespace, it will go to the
    # method_missing for the namespace. This will see that there is an option and go ahead and
    # define the reader/writer on the namespace. To do this, the option definition is found, and
    # then duplicated with the namespace option method. The value that is currently set is also
    # kept.
    def fetch_and_define_option(namespace, option_name)
      option = namespace.options[option_name]
      new_option = namespace.option(option.name, option.type_class, option.rules)
      new_option.value = option.value
      new_option
    end

  end

end
