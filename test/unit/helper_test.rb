require 'assert'

module NsOptions::Helper

  class BaseTest < Assert::Context
    desc "NsOptions::Helper"
    setup do
      @module = NsOptions::Helper
    end
    subject{ @module }

    should have_instance_method :advisor

    should "return an instance of NsOptions::Helper::Advisor with a call to #advisor" do
      advisor = subject.advisor(NsOptions::Namespace.new("something"))
      assert_instance_of NsOptions::Helper::Advisor, advisor
    end
  end

end
