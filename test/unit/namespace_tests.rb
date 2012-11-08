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
    should have_imeths :define, :build_from, :reset, :apply, :to_hash, :each

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

    should "advise on the option name" do
      not_recommended_warn = NsOptions::TestOutput.capture do
        subject.option 'to_hash'
      end
      assert_match 'WARNING: ', not_recommended_warn

      subject.option 'opt1'
      duplicate_warn = NsOptions::TestOutput.capture do
        subject.option 'opt1'
      end
      assert_match 'WARNING: ', duplicate_warn
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

    should "add a child namespace to the namespace" do
      assert subject.has_namespace? :something

      ns = subject.something
      assert_kind_of NsOptions::Namespace, ns
      assert_equal 'something', ns.__data__.name
      assert ns.has_option? :something_else
    end

    should "define on the namespace if it is called with a block" do
      ns = subject.something
      assert_not ns.has_option? :defined_later

      subject.something { option :defined_later }
      assert ns.has_option? :defined_later
    end

    should "advise the namespace name" do
      not_recommended_warn = NsOptions::TestOutput.capture do
        subject.namespace 'to_hash'
      end
      assert_match 'WARNING: ', not_recommended_warn

      subject.namespace 'opt1'
      duplicate_warn = NsOptions::TestOutput.capture do
        subject.namespace 'opt1'
      end
      assert_match 'WARNING: ', duplicate_warn
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
      assert_responds_to     :not_pre_defined=, subject
      assert_not_responds_to :not_pre_defined, subject

      assert_nothing_raised { subject.not_pre_defined = 123 }

      assert subject.has_option? :not_pre_defined
      assert_responds_to :not_pre_defined, subject

      assert_equal 123, subject.not_pre_defined
      assert_equal Object, subject.__data__.child_options['not_pre_defined'].type_class
    end

  end

  class ApplyTests < BaseTests
    setup do
      @namespace.define do
        option :first; option :second; option :third
        namespace(:child_a) do
          option(:fourth); option(:fifth)
          namespace(:child_b) { option(:sixth) }
        end
      end

      @named_values = {
        :first => "1", :second => "2", :third => "3", :twenty_one => "21",
        :child_a => {
          :fourth => "4", :fifth => "5",
          :child_b => { :sixth => "6" }
        },
        :child_c => { :what => "?" }
      }
    end

    should "apply a given hash value to itself" do
      subject.apply(@named_values)
      assert_equal @named_values, subject.to_hash
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
