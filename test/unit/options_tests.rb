require 'assert'
require 'ns-options/options'

class NsOptions::Options

  class BaseTests < Assert::Context
    desc "NsOptions::Options"
    setup do
      @options = NsOptions::Options.new
    end
    subject{ @options }

    should have_accessor :[]
    should have_imeths :keys, :each, :empty?
    should have_imeths :add, :rm, :get, :set, :required_set?

    should "only use strings for keys (indifferent access)" do
      subject['string_key'] = true
      subject[:symbol_key]  = true

      assert_includes 'string_key', subject.keys
      assert_includes 'symbol_key', subject.keys
      assert_not_includes :string_key, subject.keys
    end

  end

  class AddTests < BaseTests
    desc "add method"

    should "add options" do
      assert_nil subject[:my_string]
      subject.add(:my_string)
      assert subject[:my_string]
    end

    should "should work with both string and symbol names" do
      assert_nil subject[:my_string]
      subject.add('my_string')
      assert subject[:my_string]
    end

    should "return the option added" do
      added_opt = subject.add(:something)
      assert_kind_of NsOptions::Option, added_opt
    end

    should "build options with args when adding" do
      subject.add(:my_float, Float, { :default => 1.0 })

      assert_equal Float, subject[:my_float].type_class
      assert_equal 1.0,   subject[:my_float].rules[:default]
    end

  end

  class RmTests < BaseTests
    desc "rm method"
    setup do
      @options.add(:my_string)
    end

    should "remove the option definition from the collection" do
      assert subject[:my_string]
      subject.rm(:my_string)
      assert_nil subject[:my_string]
    end

    should "should work with both string and symbol names" do
      assert subject[:my_string]
      subject.rm('my_string')
      assert_nil subject[:my_string]
    end

  end

  class GetTests < BaseTests
    desc "get method"
    setup do
      @options.add(:my_string, { :default => "something" })
    end

    should "return the named option value" do
      assert_equal "something", subject.get(:my_string)
    end

    should "should work with both string and symbol names" do
      assert_equal "something", subject.get('my_string')
    end

  end

  class SetTests < BaseTests
    desc "set method"
    setup do
      @options.add(:my_string)
    end

    should "set option values" do
      assert_nil subject[:my_string].value
      subject.set(:my_string, "something")

      assert_equal "something", subject.get(:my_string)
    end

    should "should work with both string and symbol names" do
      assert_nil subject[:my_string].value
      subject.set('my_string', "something")

      assert_equal "something", subject.get(:my_string)
    end

  end

  class RequiredSetTests < BaseTests
    desc "required_set? method"
    setup do
      @options.add(:first, String, { :require => true })
      @options.add(:second, String, { :required => true })
      @options.add(:third, String)
    end

    should "return true when all required options are set" do
      subject.set(:first, "first")
      subject.set(:second, "second")

      assert_equal true, subject.required_set?
    end

    should "return false if one required option is not set" do
      subject.set(:first, "first")
      subject.set(:third, "third")

      assert_equal false, subject.required_set?
    end

    should "not change because of options that aren't required" do
      subject.set(:first, "first")
      subject.set(:second, "second")
      subject.set(:third, "third")
      assert_equal true, subject.required_set?

      subject.set(:third, nil)
      assert_equal true, subject.required_set?
    end

  end

end
