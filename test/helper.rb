$LOAD_PATH.unshift(File.expand_path("../..", __FILE__))

module NsOptions
  module TestOutput

    module_function

    def capture
      out = ""
      io = StringIO.new(out)
      $stdout = io
      yield
      return out
    ensure
      $stdout = STDOUT
    end

  end
end

