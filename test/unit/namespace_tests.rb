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

    should have_reader :__name__, :__data__
    should have_imeths :option, :opt, :namespace, :ns
    should have_imeths :option_type_class, :opt_type_class
    should have_imeths :required_set?, :valid?
    should have_imeths :has_option?, :has_namespace?
    should have_imeths :define, :build_from, :reset, :apply, :to_hash, :each

    should "know its name" do
      assert_equal @name, subject.__name__
    end

    should "contain its name key in its inspect output" do
      assert_included ":something", subject.inspect
    end

    should "contain its to_hash representation in its inspect output" do
      assert_included subject.to_hash.inspect, subject.inspect
    end

    should "still work if to_hash raises an exception" do
      subject.option(:something, :default => proc{ raise 'test' })

      output = nil
      assert_nothing_raised{ output = subject.inspect }
      assert_includes "error getting inspect details", output
    end

    should "know its option type class" do
      assert_equal Object, subject.option_type_class
    end

    should "set its option type class" do
      subject.option_type_class(String)
      assert_equal String, subject.option_type_class
    end

  end

  class OptionTests < BaseTests
    desc "when adding an option named `something`"
    setup do
      @added_opt = @namespace.option('something', Fixnum, { :default => 1 })
    end

    should "have added an option to the namespace" do
      assert subject.has_option? :something

      opt = subject.__data__.child_options[:something]
      assert_equal 'something',  opt.name
      assert_equal Fixnum,  opt.type_class
      assert_equal 1, opt.rules[:default]
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

    should "respond to a reader/writer named after the option name" do
      assert_responds_to :something, subject
      assert_responds_to :something=, subject
    end

    should "return the option using the reader" do
      assert_equal subject.__data__.child_options.get(:something), subject.something
    end

    should "be writable through the defined writer" do
      assert_nothing_raised{ subject.something = 2 }
      assert_equal 2, subject.something
    end

    should "be writable through the reader with args" do
      assert_nothing_raised{ subject.something 3 }
      assert_equal 3, subject.something
    end

    should "raise CoerceError when writing values not coercable to the type class" do
      err = begin
        subject.something = "can't be coerced to a Fixnum!"
      rescue Exception => err
        err
      end

      assert_equal NsOptions::Option::CoerceError,  err.class
      assert_included 'test/unit/namespace_tests.rb:', err.backtrace.first
    end

  end

  class NamespaceTests < BaseTests
    desc "when adding a namespace named `something`"
    setup do
      @namespace.namespace('something') do
        option :something_else
      end
    end

    should "know that it has the child namespace" do
      assert subject.has_namespace? :something

      ns = subject.something
      assert_kind_of NsOptions::Namespace, ns
      assert_equal 'something', ns.__name__
      assert ns.has_option? :something_else
    end

    should "respond to a reader named after the namespace name" do
      assert_responds_to :something, subject
    end

    should "return the namespace using the reader" do
      assert_equal subject.__data__.child_namespaces[:something], subject.something
    end

    should "define on the namespace if it is called with a block" do
      ns = subject.something
      assert_not ns.has_option? :defined_later

      subject.something { option :defined_later }
      assert ns.has_option? :defined_later
    end

    should "advise on the namespace name" do
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

  class DynamicOptionNamespaceWriterTests < BaseTests

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

    should "raise NoMethodError when writing namespace values" do
      subject.namespace('something')

      assert_raises NoMethodError do
        subject.something = 'a value'
      end
      assert_raises NoMethodError do
        subject.something = {:a => 'value'}
      end
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
