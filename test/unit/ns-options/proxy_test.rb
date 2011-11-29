require 'assert'

module NsOptions::Proxy

  class BaseTests < Assert::Context
    desc "NsOptions::Proxy"

    def self.proxy_a_namespace
      Assert::Macro.new do
        should "create a default namespace to proxy to" do
          assert_respond_to NAMESPACE, subject
          assert_kind_of NsOptions::Namespace, subject.send(NAMESPACE)
        end

        should "respond to namespace methods" do
          assert_respond_to :option, subject
          assert_respond_to :namespace, subject
          assert_respond_to :to_hash, subject
          assert_respond_to :each, subject
        end

      end
    end

  end

  class ModuleTests < BaseTests
    desc "when mixed in to a module"
    setup do
      @mod = Module.new do
        include NsOptions
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
        include NsOptions
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
