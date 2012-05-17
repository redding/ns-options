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
          assert_respond_to :namespace,     subject
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
      end
    end
    subject { @mod }

    should proxy_a_namespace

  end

  class ClassTests < BaseTests
    desc "when mixed into a class"
    setup do
      @cls = Class.new do
        include NsOptions::Proxy
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

  end

end
