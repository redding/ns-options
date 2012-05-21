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
          assert_respond_to :option,        subject
          assert_respond_to :opt,           subject
          assert_respond_to :namespace,     subject
          assert_respond_to :ns,            subject
          assert_respond_to :apply,         subject
          assert_respond_to :to_hash,       subject
          assert_respond_to :each,          subject
          assert_respond_to :define,        subject
          assert_respond_to :inspect,       subject
          assert_respond_to :required_set?, subject
          assert_respond_to :valid?,        subject
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

end
