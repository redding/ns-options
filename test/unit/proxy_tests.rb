require 'assert'

module NsOptions::Proxy

  class BaseTests < Assert::Context
    desc "NsOptions::Proxy"

    def self.proxy_a_namespace
      Assert::Macro.new do
        should "create a default namespace to proxy to" do
          assert_respond_to '__proxy_options__', subject
          assert_kind_of NsOptions::Namespace, subject.send('__proxy_options__')
        end

        should "respond to proxied namespace methods" do
          assert_respond_to :option,            subject
          assert_respond_to :opt,               subject
          assert_respond_to :option_type_class, subject
          assert_respond_to :opt_type_class,    subject
          assert_respond_to :namespace,         subject
          assert_respond_to :ns,                subject
          assert_respond_to :apply,             subject
          assert_respond_to :to_hash,           subject
          assert_respond_to :each,              subject
          assert_respond_to :define,            subject
          assert_respond_to :build_from,        subject
          assert_respond_to :reset,             subject
          assert_respond_to :inspect,           subject
          assert_respond_to :has_option?,       subject
          assert_respond_to :has_namespace?,    subject
          assert_respond_to :required_set?,     subject
          assert_respond_to :valid?,            subject
          assert_respond_to :__data__,          subject
        end

        should "create options directly" do
          assert_nothing_raised do
            subject.option :test_opt
          end
        end

        should "create namespaces directly" do
          assert_nothing_raised do
            subject.namespace :test_ns
          end
        end


      end
    end

  end

  class ModuleTests < BaseTests
    desc "when mixed in to a module"
    setup do
      @mod = Module.new do
        include NsOptions::Proxy

        option :test
      end
    end
    subject { @mod }

    should proxy_a_namespace

    should "allow building from a hash of key-values" do
      subject.new('test' => 1, 'more' => 2)

      assert_equal 1, subject.test
      assert_equal 2, subject.more
    end

    should "take `new` method overrides" do
      @newmod = Module.new do
        include NsOptions::Proxy

        def self.new
          # nothing
        end
      end

      assert_raises ArgumentError do
        @newmod.new('test' => 1, 'more' => 2)
      end
    end

  end

  class ClassTests < BaseTests
    desc "when mixed into a class"
    setup do
      @cls = Class.new do
        include NsOptions::Proxy

        option :test
      end
    end

  end

  class ClassLevelTests < ClassTests
    subject { @cls }
    should proxy_a_namespace

  end

  class InstanceLevelTests < ClassTests
    subject { @cls.new }
    should proxy_a_namespace

    should "allow building from a hash of key-values" do
      thing = @cls.new(:test => 1, :more => 2)

      assert_equal 1, thing.test
      assert_equal 2, thing.more
    end

    should "take init method overrides" do
      @newcls = Class.new do
        include NsOptions::Proxy

        def initialize
          # nothing
        end
      end

      assert_raises ArgumentError do
        @newcls.new('test' => 1, 'more' => 2)
      end
    end

  end

  class EqualityTests < InstanceLevelTests
    desc "two class instance proxies with the same option values"
    setup do
      @proxy1 = @cls.new
      @proxy2 = @cls.new

      @option_values = {:test => 1, :more => 2}

      @proxy1.apply(@option_values)
      @proxy2.apply(@option_values)
    end

    should "be equal to the each other" do
      assert_equal @proxy2, @proxy1
    end

  end

  class DynamicOptionWriterTests < BaseTests
    setup do
      @mod = Module.new do
        include NsOptions::Proxy

        option :test
      end
    end
    subject { @mod }

    should "write non-pre-defined values as Object options" do
      assert_not subject.has_option? :not_pre_defined
      assert_responds_to :not_pre_defined=, subject
      assert_not_responds_to :not_pre_defined, subject

      assert_nothing_raised { subject.not_pre_defined = 123 }

      assert subject.has_option? :not_pre_defined
      assert_responds_to :not_pre_defined, subject

      assert_equal 123, subject.not_pre_defined
      assert_equal Object, subject.__data__.child_options['not_pre_defined'].type_class
    end

  end

  class InheritedTests < BaseTests
    desc "when inherited"
    setup do
      @a_super_class = Class.new do
        include NsOptions::Proxy
        option_type_class Fixnum

        option :test
        namespace(:other) { option :stuff }
      end
    end

    should "should have its proxy namespace built on inheriting" do
      super_ns = @a_super_class.instance_variable_get("@__proxy_options__")
      assert_not_nil super_ns
      assert_kind_of NsOptions::Namespace, super_ns

      a_sub_class = Class.new(@a_super_class)
      sub_ns = a_sub_class.instance_variable_get("@__proxy_options__")
      assert_not_nil sub_ns
      assert_kind_of NsOptions::Namespace, sub_ns

      assert_not_same super_ns, sub_ns
    end

    should "pass its definition to any subclass" do
      a_sub_class = Class.new(@a_super_class)

      assert a_sub_class.has_option? :test
      assert a_sub_class.has_namespace? :other
      assert a_sub_class.other.has_option? :stuff

      a_sub_ns_data = a_sub_class.__proxy_options__.__data__
      assert_equal Fixnum, a_sub_ns_data.option_type_class
      other_ns_data = a_sub_class.other.__data__
      assert_equal Fixnum, other_ns_data.option_type_class
    end

  end

end
