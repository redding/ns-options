require 'ns-options/option'

module NsOptions
  class Options < Hash

    # for hash with indifferent access behavior
    def [](name);         super(name.to_sym);        end
    def []=(name, value); super(name.to_sym, value); end

    def add(*args)
      option = NsOptions::Option.new(*args)
      self[option.name] = option
    end

    def rm(name)
      self[name] = nil
    end

    def get(name)
      (option = self[name]) ? option.value : nil
    end

    def set(name, new_value)
      self[name].value = new_value
    end

    def required_set?
      self.values.reject{|option| !option.required? }.inject(true) do |bool, option|
        bool && option.is_set?
      end
    end

  end
end
