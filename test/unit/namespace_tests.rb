require 'assert'
require 'ns-options/namespace'

class NsOptions::Namespace

  class BaseTests < Assert::Context
    desc "NsOptions::Namespace"
    setup do
      @name = "something"
      @namespace = NsOptions::Namespace.new(@name)
    end
    subject{ @namespace }

    should have_reader :__data__
    should have_imeths :option, :opt, :namespace, :ns
    should have_imeths :required_set?, :valid?, :has_option?, :has_namespace?
    should have_imeths :define, :build_from, :apply, :to_hash, :each

    should "contain its name key in its inspect output" do
      assert_included ":something", subject.inspect
    end

    should "contain its to_hash representation in its inspect output" do
      assert_included subject.to_hash.inspect, subject.inspect
    end

  end

  class OptionTests < BaseTests
    setup do
      @added_opt = @namespace.option('something', String, { :default => true })
    end
  end

  class OptionMethTests < OptionTests
    desc "option method"
    teardown do
      # TODO: why?
      NsOptions::Helper.unstub(:advisor)
    end
    subject{ @namespace }

    should "add an option to the namespace" do
      assert subject.has_option? :something

      opt = subject.__data__.child_options[:something]
      assert_equal 'something',  opt.name
      assert_equal String,  opt.type_class
      assert_equal true, opt.rules[:default]
    end

    should "return the option it added" do
      assert_kind_of NsOptions::Option, @added_opt

      option = subject.__data__.child_options[:something]
      assert_equal option, @added_opt
    end

    should "check if the option name is ok" do
      # TODO: needed??
      advisor = NsOptions::Helper::Advisor.new(@namespace)
      NsOptions::Helper.expects(:advisor).with(@namespace).returns(advisor)
      advisor.expects(:is_this_option_ok?)
      assert_nothing_raised do
        @namespace.option(:amazing)
      end
    end
  end

  class AddedOptionTests < OptionTests
    desc "after adding an option named `something`"

    should "respond to a reader/writer named after the option name" do
      assert_responds_to :something, subject
      assert_responds_to :something=, subject
    end

    should "be return the option using the reader" do
      assert_equal subject.__data__.child_options.get(:something), subject.something
    end

    should "be writable through the defined writer" do
      assert_nothing_raised{ subject.something = "abc" }
      assert_equal "abc", subject.something
    end

    should "be writable through the reader with args" do
      assert_nothing_raised{ subject.something "123" }
      assert_equal "123", subject.something
    end

  end

  class NamespaceTests < BaseTests
    setup do
      @namespace.namespace('something') do
        option :something_else
      end
    end
  end

  class NamespaceMethTests < NamespaceTests
    desc "namespace method"
    teardown do
      NsOptions::Helper.unstub(:advisor)
    end

    should "add a child namespace to the namespace" do
      assert subject.has_namespace? :something

      ns = subject.__data__.child_namespaces[:something]
      assert_equal 'something', ns.__data__.name
      assert_kind_of NsOptions::Option, ns.__data__.child_options[:something_else]
    end

    should "check if the namespace name is ok" do
      # TODO: needed??
      advisor = NsOptions::Helper::Advisor.new(@namespace)
      NsOptions::Helper.expects(:advisor).with(@namespace).returns(advisor)
      advisor.expects(:is_this_sub_namespace_ok?)
      assert_nothing_raised do
        @namespace.namespace(:yet_another)
      end
    end

  end

  class AddedNamespaceTests < NamespaceTests
    desc "after adding a namespace named `something`"

    should "respond to a reader named after the namespace name" do
      assert_responds_to :something, subject
    end

    should "be return the namespace using the reader" do
      assert_equal subject.__data__.child_namespaces[:something], subject.something
    end

  end

  class DynamicOptionWriterTests < BaseTests

    should "write non-pre-defined values as Object options" do
      assert_not subject.has_option? :not_pre_defined
      assert_not_responds_to :not_pre_defined, subject
      assert_not_responds_to :not_pre_defined=, subject

      assert_nothing_raised { subject.not_pre_defined = 123 }

      assert subject.has_option? :not_pre_defined
      assert_responds_to :not_pre_defined, subject
      assert_responds_to :not_pre_defined=, subject

      assert_equal 123, subject.not_pre_defined
      assert_equal Object, subject.__data__.child_options['not_pre_defined'].type_class
    end

  end

  class EqualityTests < BaseTests
    desc "when compared for equality"
    setup do
      @named_values = {:some => 'value', 'another' => 'value'}
      @namespace.apply(@named_values)
    end

    should "be equal to another namespace with the same named values" do
      other_ns = NsOptions::Namespace.new('other_something')
      other_ns.apply(@named_values)

      assert_equal other_ns, subject
    end

    should "not be equal to another namespace with different values" do
      other_ns = NsOptions::Namespace.new('other_something')
      other_ns.apply({:other => 'data'})

      assert_not_equal other_ns, subject
    end

    should "not be equal to other things" do
      assert_not_equal 1, subject
      assert_not_equal @named_values, subject
    end

  end

end
