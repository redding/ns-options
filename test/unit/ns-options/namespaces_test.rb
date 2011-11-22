require 'assert'

class NsOptions::Namespaces

  class BaseTest < Assert::Context
    desc "NsOptions::Namespaces"
    setup do
      @namespaces = NsOptions::Namespaces.new
    end
    subject{ @namespaces }

    should have_instance_methods :add, :get

    should "be a kind of a hash" do
      assert_kind_of Hash, subject
    end
    should "only use symbols for keys" do
      subject["string_key"] = true
      subject[:symbol_key] = true

      assert_includes :string_key, subject.keys
      assert_includes :symbol_key, subject.keys
      assert_not_includes "string_key", subject.keys
    end
  end

  class AddTest < BaseTest
    desc "add method"
    setup do
      @parent = NsOptions::Namespace.new(:parent)
      @namespaces.add(:a_name, "a-key", @parent) do
        option :an_option
      end
    end
    subject{ @namespaces }

    should "have created a new namespace and added it to itself" do
      assert(namespace = subject[:a_name])
      assert_kind_of NsOptions::Namespace, namespace
      assert_equal "a-key", namespace.options.key
      assert_equal @parent, namespace.options.parent
      assert namespace.options[:an_option]
    end
  end

  class GetTest < AddTest
    desc "get method"

    should "return the namespace matching the name" do
      assert(namespace = subject.get("a_name"))
      assert_equal subject[:a_name], namespace
    end
  end

end
