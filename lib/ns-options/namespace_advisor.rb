module NsOptions

  class NamespaceAdvisor

    def initialize(ns_data, name, kind)
      @ns_data = ns_data
      @name = name

      @msg = if not_recommended?
        "WARNING: Defining #{kind} with the name `#{@name}' overwrites a method"\
        " NsOptions depends on.  It may cause NsOptions to behave oddly and"\
        " is not recommended."
      elsif duplicate?
        "WARNING: `#{@name}' has already been defined and is being overwritten."
      end
    end

    def run(io, from_caller)
      return true if @msg.nil?

      io.puts @msg
      io.puts from_caller.first
      false
    end

    def not_recommended?; not_recommended_names.include?(@name.to_sym); end
    def duplicate?; @ns_data.has_option?(@name) || @ns_data.has_namespace?(@name); end

    def not_recommended_names
      NsOptions::Namespace.instance_methods(false).map(&:to_sym)
    end

  end

end
