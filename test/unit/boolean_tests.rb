require 'assert'
require 'ns-options/boolean'

class NsOptions::Boolean

  class BaseTests < Assert::Context
    desc "NsOptions::Boolean"
    setup do
      @boolean = NsOptions::Boolean.new(true)
    end
    subject{ @boolean }

    should have_accessor :actual
    should have_reader   :returned_value

    should "return its handled value with the `actual` method" do
      assert_equal true, subject.actual
    end

    should "return its handled value with the `returned_value` method" do
      assert_equal true, subject.returned_value
    end

  end

  class WithTruthyValuesTests < BaseTests
    desc "with truthy values"
    setup do
      @boolean = NsOptions::Boolean.new(nil)
    end

    should "have set actual to true with true" do
      subject.actual = true
      assert_equal true, subject.actual
    end
    should "have set actual to true with 'true'" do
      subject.actual = 'true'
      assert_equal true, subject.actual
    end
    should "have set actual to true with 't'" do
      subject.actual = 't'
      assert_equal true, subject.actual
    end
    should "have set actual to true with 'T'" do
      subject.actual = 'T'
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

  class WithFalsyValuesTests < BaseTests
    desc "with falsy values"
    setup do
      @boolean = NsOptions::Boolean.new(nil)
    end

    should "have set actual to false with false" do
      subject.actual = false
      assert_equal false, subject.actual
    end
    should "have set actual to false with 'false'" do
      subject.actual = 'false'
      assert_equal false, subject.actual
    end
    should "have set actual to false with 'f'" do
      subject.actual = 'f'
      assert_equal false, subject.actual
    end
    should "have set actual to false with 'F'" do
      subject.actual = 'F'
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

  class ComparatorTests < BaseTests
    desc "when comparing for equality"
    setup do
      @true_bool   = NsOptions::Boolean.new true
      @false_bool  = NsOptions::Boolean.new false
    end

    should "compare with other booleans" do
      assert_equal NsOptions::Boolean.new(1), @true_bool
      assert_equal NsOptions::Boolean.new(0), @false_bool
    end

    should "compare with true and false" do
      assert_equal true, @true_bool
      assert_equal false, @false_bool
    end
  end

end
