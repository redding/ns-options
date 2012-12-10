require 'assert'
require 'ns-options/proxy'
require 'ns-options/struct'

module NsOptions::Struct

  class BaseTests < Assert::Context
    desc "NsOptions::Struct"
    setup do
      @struct = NsOptions::Struct.new
    end
    subject { @struct }

    should "be a proxy class" do
      assert_kind_of ::Class, subject
      assert subject.ancestors.include?(::NsOptions::Proxy)
    end

  end

  class StructGlobalTests < BaseTests
    desc "assigned to a global"
    setup do
      Thing = NsOptions::Struct.new
    end
    subject { Thing }

    should "be a proxy class" do
      assert_kind_of ::Class, subject
      assert subject.ancestors.include?(::NsOptions::Proxy)
    end

  end

  class StructClassTests < BaseTests
    desc "used as the superclass to another class"
    setup do
      Thing = Class.new(NsOptions::Struct.new)
    end
    subject { Thing }

    should "be a proxy class" do
      assert_kind_of ::Class, subject
      assert subject.ancestors.include?(::NsOptions::Proxy)
    end

  end

  class StructureTests < BaseTests
    desc "created with a structure and values"
    setup do
      @struct = NsOptions::Struct.new(:a => 'aye') do
        option :b, Symbol, :default => :bee
        option :c
      end
    end

    should "should define the structure and apply the values" do
      assert_equal 'aye', subject.a
      assert_equal :bee,  subject.b
      assert_nil subject.c
    end

  end

end
