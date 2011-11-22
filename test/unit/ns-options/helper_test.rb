require 'assert'

module NsOptions::Helper

  class BaseTest < Assert::Context
    desc "NsOptions::Helper"
    setup do
      @module = NsOptions::Helper
    end
    subject{ @module }

    should have_instance_methods :fetch_and_define_option

  end

end
