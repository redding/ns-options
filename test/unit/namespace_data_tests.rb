require 'assert'
require 'ns-options/namespace_data'
require 'ns-options/namespace'

class NsOptions::NamespaceData

  class BaseTests < Assert::Context
    desc "NsOptions::NamespaceData"
    setup do
      @ns = NsOptions::Namespace.new('thing')
      @data = @ns.__data__
    end
    subject { @data }

    should have_readers :ns, :option_type_class
    should have_readers :child_options, :child_namespaces
    should have_imeths  :has_option?, :has_namespace?, :required_set?
    should have_imeths  :add_option, :get_option, :set_option
    should have_imeths  :add_namespace, :get_namespace
    should have_imeths  :set_option_type_class
    should have_imeths  :to_hash, :apply, :each, :define, :build_from, :reset

    should "know its namespace" do
      assert_equal @ns, subject.ns
    end

    should "know its type class" do
      assert_equal Object, subject.option_type_class
    end

    should "know its child options" do
      assert_kind_of NsOptions::Options, subject.child_options
      assert_empty subject.child_options
    end

    should "know its child namespaces" do
      assert_kind_of NsOptions::Namespaces, subject.child_namespaces
      assert_empty subject.child_namespaces
    end

    should "be able to change its option_type_class" do
      assert_equal Object, subject.option_type_class
      subject.set_option_type_class(Fixnum)

      assert_equal Fixnum, subject.option_type_class
    end

    should "add options" do
      an_option = subject.add_option 'an_option'

      assert_equal an_option, subject.child_options['an_option']
      assert_equal Object, an_option.type_class
    end

    should "add options with its type class" do
      subject.set_option_type_class(Fixnum)
      an_option = subject.add_option 'an_option'

      assert_equal Fixnum, an_option.type_class
    end

    should "get option values" do
      an_option = subject.add_option 'an_option'
      an_option.value = 123

      assert_equal 123, subject.get_option('an_option')
    end

    should "set option values" do
      an_option = subject.add_option 'an_option'
      an_option.value = 123
      subject.set_option('an_option', 456)

      assert_equal 456, an_option.value
    end

    should "add namespaces" do
      a_namespace = subject.add_namespace 'a_namespace'
      assert_equal a_namespace, subject.child_namespaces['a_namespace']

      a_ns_data   = a_namespace.__data__
      assert_equal Object, a_ns_data.option_type_class
    end

    should "add namespaces with its type class" do
      subject.set_option_type_class(Fixnum)
      a_namespace = subject.add_namespace 'a_namespace'
      a_ns_data   = subject.child_namespaces['a_namespace'].__data__

      assert_equal Fixnum, a_ns_data.option_type_class
    end

    should "get namespaces" do
      a_namespace = subject.add_namespace 'a_namespace'
      assert_equal a_namespace, subject.get_namespace('a_namespace')
    end

  end

  class HandlingTests < BaseTests
    setup do
      @data.define do
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

    should "know if it has an option" do
      assert subject.has_option? 'first'
      assert_not subject.has_option? 'blashalksjdglasjasdga'
    end

    should "know if it has a namespace" do
      assert subject.has_namespace? 'child_a'
      assert_not subject.has_namespace? 'dlakjsglasdjgaklsdgjas'
    end

  end

  class EachTests < HandlingTests
    desc "iterated with the each method"
    setup do
      subject.apply(@named_values)
      @exp = "".tap do |exp|
        subject.to_hash.each do |k,v|
          exp << "#{k}=#{v};"
        end
      end
      @act = "".tap do |exp|
        subject.each do |k,v|
          exp << "#{k}=#{v};"
        end
      end
    end

    should "yield k/v pairs by iterating over the #to_hash" do
      assert_equal @exp, @act
    end

  end

  class DefineTests < BaseTests
    desc "define method"

    should "instance eval in the scope of the ns if given a no-arity-block" do
      scope = nil; subject.define{ scope = self }
      assert_equal @ns, scope
    end

    should "yield the ns to the block if given an arity-block" do
      yielded = nil; subject.define{|ns| yielded = ns}
      assert_equal @ns, yielded
    end

    should "return the namespace, if given no block" do
      assert_equal @ns, subject.define
    end

  end

  class BuildFromTests < BaseTests
    desc "build_from method"
    setup do
      @from_ns = NsOptions::Namespace.new(:other_thing)
      @from_child_opt = @from_ns.option :opt1
      @from_child_ns  = @from_ns.namespace(:ns1) { option :sub_opt1 }
    end

    should "copy the options" do
      assert_not subject.has_option? :opt1
      @data.build_from(@from_ns.__data__)

      assert subject.has_option? :opt1
      assert_not_same @from_child_opt, subject.child_options[:opt1]
    end

    should "copy the namespaces" do
      assert_not subject.has_namespace?(:ns1)
      @data.build_from(@from_ns.__data__)

      assert subject.has_namespace?(:ns1)
      assert subject.child_namespaces[:ns1].__data__.has_option? :sub_opt1
      assert_not_same @from_child_ns, subject.child_namespaces[:ns1]
    end

  end

  class HashHandlingTests < BaseTests
    setup do
      @data.define do
        option :first; option :second; option :third
        namespace(:child_a) do
          option(:fourth); option(:fifth)
          namespace(:child_b) { option(:sixth) }
        end
      end

      @shared_array = []
      @named_values = {
        :first => "1", :second => "2", :third => "3", :twenty_one => "21",
        :child_a => {
          :fourth => "4", :fifth => "5",
          :child_b => { :sixth => "6" }
        },
        :child_c => { :what => "?" },
        :shared => @shared_array
      }
    end

  end

  class ToHashTests < HashHandlingTests

    should "return its Hash representation" do
      exp_hash = {
        :first => nil, :second => nil, :third => nil,
        :child_a => {
          :fourth => nil, :fifth => nil,
          :child_b => { :sixth => nil }
        }
      }
      assert_equal(exp_hash, subject.to_hash)
    end

    should "use distinct values in its Hash representation" do
      subject.add_option(:shared)
      subject.set_option(:shared, [])
      hash_rep = subject.to_hash
      subject.get_option(:shared) << 1

      assert_not_empty subject.get_option(:shared)
      assert_empty     hash_rep[:shared]
      assert_not_equal subject.get_option(:shared).object_id, hash_rep[:shared].object_id
    end

  end

  class ApplyTests < HashHandlingTests

    should "apply a given hash value to itself" do
      subject.apply(@named_values)
      assert_equal @named_values, subject.to_hash
    end

    should "use distinct values when applying hashes" do
      subject.apply(@named_values)
      @shared_array << 1

      assert_empty subject.get_option(:shared)
      assert_not_equal @shared_array.object_id, subject.get_option(:shared).object_id
    end

    should "ignore applying non-hash values to namespaces" do
      assert_nil subject.ns.child_a.fourth
      prev_child_b = subject.ns.child_a.child_b.dup

      subject.apply(:child_a => {
        :fourth => 4,
        :child_b => 'something'
      })
      assert_equal 4, subject.ns.child_a.fourth
      assert_not_equal 'something', subject.ns.child_a.child_b
      assert_equal prev_child_b, subject.ns.child_a.child_b
    end

  end

  class ResetTests < BaseTests
    desc "reset method"
    setup do
      @data.add_option 'fixnum', Fixnum, :default => 10
      @data.add_option 'something'
      @data.add_namespace 'sub' do
        option 'subopt'
      end

      @data.set_option 'fixnum', 9999
      @data.set_option 'something', 'else'
      @data.get_namespace('sub').subopt = "a subopt"
    end

    should "set the options back to their default values" do
      assert_equal 9999, subject.get_option('fixnum')
      assert_equal 'else', subject.get_option('something')
      assert_equal 'a subopt', subject.get_namespace('sub').subopt

      subject.reset

      assert_equal 10, subject.get_option('fixnum')
      assert_nil subject.get_option('something')
      assert_nil subject.get_namespace('sub').subopt
    end

  end

  class SameNameTests < BaseTests

    should "replace a same-named option when adding a new option" do
      subject.add_option :something, String
      assert subject.has_option? :something

      subject.add_option :something, Fixnum, :default => 10
      assert subject.has_option? :something

      opt = subject.child_options[:something]
      assert_equal Fixnum, opt.type_class
      assert_equal 10,     opt.rules[:default]
    end

    should "replace a same-named option when adding a new namespace" do
      subject.add_option :something, String
      assert subject.has_option? :something

      subject.add_namespace :something
      assert_not subject.has_option?    :something
      assert     subject.has_namespace? :something

      assert_equal Hash.new, subject.child_namespaces[:something].to_hash
    end

    should "replace a same-named namespace when adding a new namespace" do
      subject.add_namespace :something do
        option :a, :default => 10
      end
      assert subject.has_namespace? :something
      assert_equal({:a => 10}, subject.child_namespaces[:something].to_hash)

      subject.add_namespace :something
      assert subject.has_namespace? :something
      assert_equal Hash.new, subject.child_namespaces[:something].to_hash
    end

    should "replace a same-named namespace when adding a new option" do
      subject.add_namespace :something
      assert subject.has_namespace? :something

      subject.add_option :something, Fixnum, :default => 10
      assert_not subject.has_namespace? :something
      assert     subject.has_option?    :something

      opt = subject.child_options[:something]
      assert_equal Fixnum, opt.type_class
      assert_equal 10,     opt.rules[:default]
    end

  end

end
