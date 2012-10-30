require 'assert'
require 'ns-options/namespace_advisor'
require 'ns-options/namespace_data'
require 'ns-options/namespace'

class NsOptions::NamespaceAdvisor

  class BaseTests < Assert::Context
    desc "NsOptions::NamespaceAdvisor"
    setup do
      @ns = NsOptions::Namespace.new 'test'
      @ns.option 'opt1'
      @ns.namespace 'ns1'
      @ns_data = @ns.__data__
      @na = ns_advisor_for 'test'
    end
    subject { @na }

    def ns_advisor_for(name, kind='an option')
      NsOptions::NamespaceAdvisor.new(@ns_data, name, kind)
    end

    should have_imeths :run, :not_recommended?, :duplicate?, :not_recommended_names

    should "know its not recommended names" do
      exp = NsOptions::Namespace.instance_methods(false).map(&:to_sym)
      assert_equal exp, subject.not_recommended_names
    end

    should "know if a name is not recommended" do
      assert     ns_advisor_for('option').not_recommended?
      assert     ns_advisor_for('to_hash').not_recommended?
      assert_not ns_advisor_for('test').not_recommended?
    end

    should "know if a name is a duplicate" do
      assert_not ns_advisor_for('option').duplicate?
      assert_not ns_advisor_for('to_hash').duplicate?
      assert_not ns_advisor_for('test').duplicate?
      assert     ns_advisor_for('opt1').duplicate?
      assert     ns_advisor_for('ns1').duplicate?
    end

  end

  class RunTests < BaseTests
    desc "run meth"
    setup do
      @io = StringIO.new(@out = "")
      @caller = ["a test caller"]
    end

    should "write a warning and any caller info on not recommended names" do
      ns_advisor_for('to_hash').run(@io, @caller)

      assert_match "WARNING: ", @out
      assert_match @caller.first, @out
    end

    should "write a warning and any caller info on duplicate names" do
      ns_advisor_for('opt1').run(@io, @caller)

      assert_match "WARNING: ", @out
      assert_match @caller.first, @out
    end

  end

end
