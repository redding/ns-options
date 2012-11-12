require 'assert'
require 'ns-options/namespaces'

class NsOptions::Namespaces

  class BaseTests < Assert::Context
    desc "NsOptions::Namespaces"
    setup do
      @namespaces = NsOptions::Namespaces.new
    end
    subject{ @namespaces }

    should have_instance_methods :add, :get, :required_set?

    should "only use strings for keys (indifferent access)" do
      subject['string_key'] = true
      subject[:symbol_key]  = true

      assert_includes 'string_key', subject.keys
      assert_includes 'symbol_key', subject.keys
      assert_not_includes :string_key, subject.keys
    end

    should "get items" do
      subject[:a_key] = "a key"

      assert_equal subject[:a_key], subject.get(:a_key)
      assert_equal subject[:a_key], subject.get('a_key')
    end

  end

  class AddTests < BaseTests
    desc "add method"

    should "add namespaces" do
      assert_nil subject[:a_name]
      subject.add(:a_name)
      assert subject[:a_name]
    end

    should "should work with both string and symbol names" do
      assert_nil subject[:a_name]
      subject.add('a_name')
      assert subject[:a_name]
    end

    should "return the option added" do
      added_ns = subject.add(:a_name)
      assert_kind_of NsOptions::Namespace, added_ns
    end

  end

end
