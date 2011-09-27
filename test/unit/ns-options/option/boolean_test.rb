require 'assert'

class NsOptions::Option::Boolean

  class BaseTest < Assert::Context
    desc "NsOptions::Option::Boolean"
    setup do
      @boolean = NsOptions::Option::Boolean.new(true)
    end
    subject{ @boolean }

    should have_accessors :actual
  end

  class WithTruthyValuesTest < BaseTest
    desc "with truthy values"
    setup do
      @boolean = NsOptions::Option::Boolean.new(false)
    end

    should "have set actual to true with true" do
      subject.actual = true
      assert_equal true, subject.actual
    end
    should "have set actual to true with 'true'" do
      subject.actual = 'true'
      assert_equal true, subject.actual
    end
    should "have set actual to true with 1" do
      subject.actual = 1
      assert_equal true, subject.actual
    end
    should "have set actual to true with '1'" do
      subject.actual = '1'
      assert_equal true, subject.actual
    end
  end

  class WithFalsyValuesTest < BaseTest
    desc "with falsy values"
    setup do
      @boolean = NsOptions::Option::Boolean.new(true)
    end

    should "have set actual to false with false" do
      subject.actual = false
      assert_equal false, subject.actual
    end
    should "have set actual to false with 'false'" do
      subject.actual = 'false'
      assert_equal false, subject.actual
    end
    should "have set actual to false with 0" do
      subject.actual = 0
      assert_equal false, subject.actual
    end
    should "have set actual to false with '0'" do
      subject.actual = '0'
      assert_equal false, subject.actual
    end
    should "have set actual to false with nil" do
      subject.actual = nil
      assert_equal false, subject.actual
    end
  end

end
