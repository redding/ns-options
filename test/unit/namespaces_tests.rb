require 'assert'
require 'ns-options/namespaces'

class NsOptions::Namespaces

  class BaseTests < Assert::Context
    desc "NsOptions::Namespaces"
    setup do
      @namespaces = NsOptions::Namespaces.new
    end
    subject{ @namespaces }

    should have_accessor :[]
    should have_imeths :keys, :each, :empty?
    should have_imeths :add, :get, :required_set?

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

  class RequiredSetTests < BaseTests
    desc "with a namespace with :required options"
    setup do
      @namespace = NsOptions::Namespace.new :with_required do
        option :required, :required => true
      end
      @namespaces[:with_required] = @namespace
    end

    should "know when its namespaces have all required set" do
      assert_not subject.required_set?
      @namespace.not_required = 'a value'
      assert_not subject.required_set?

      @namespace.required = 'something'
      assert subject.required_set?
    end

  end

end
