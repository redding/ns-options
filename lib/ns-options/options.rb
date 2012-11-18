require 'ns-options/option'

module NsOptions

  class Options

    def initialize
      @hash = Hash.new
    end

    # for hash with indifferent access behavior
    def [](name);         @hash[name.to_s];         end
    def []=(name, value); @hash[name.to_s] = value; end

    def keys(*args, &block);   @hash.keys(*args, &block);   end
    def each(*args, &block);   @hash.each(*args, &block);   end
    def empty?(*args, &block); @hash.empty?(*args, &block); end

    def add(*args)
      option = NsOptions::Option.new(*NsOptions::Option.args(*args))
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
      are_all_these_options_set? required_options
    end

    private

    def are_all_these_options_set?(options)
      options.inject(true) {|bool, opt| bool && opt.is_set?}
    end

    def required_options
      @hash.values.reject{|opt| !opt.required? }
    end

  end
end
