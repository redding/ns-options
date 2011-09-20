require 'logger'
require 'mocha'
require 'logger'

root_path = File.expand_path("../..", __FILE__)
if !$LOAD_PATH.include?(root_path)
  $LOAD_PATH.unshift(root_path)
end
require 'ns-options'

require 'test/support/app'
require 'test/support/user'

if defined?(Assert)

  class Assert::Context
    include Mocha::API
  end

end
