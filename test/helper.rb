# this file is automatically required when you run `assert`
# put any test helpers here

# add the root dir to the load path
ROOT_PATH = File.expand_path("../..", __FILE__)
$LOAD_PATH.unshift(ROOT_PATH)

# require pry for debugging (`binding.pry`)
require 'pry'

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

