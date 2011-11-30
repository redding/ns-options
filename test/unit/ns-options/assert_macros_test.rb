require 'assert'

module NsOptions::AssertMacros

  class BaseTests < Assert::Context
    desc "NsOptions::AssertMacros"
    include NsOptions::AssertMacros

    setup do
      @cls = Class.new do
        include NsOptions

        options(:test) do
          option :one
          option :two,   :default => 2
          option :three, :required => true
          option :four,  :args => [5,6,7]
          option :five,  Pathname, :default => '.'

          namespace :more do
            option :seven
          end
        end

      end
    end
    subject { @cls.test }

    should have_namespace :more
    should have_namespaces :more

    should have_options(:one, :two, :three, :four, :five)
    should have_option :one

    should have_option :two,   :default => 2
    should have_option :three, :required => true
    should have_option :four,  :args => [5,6,7]
    should have_option :five,  Pathname, :default => '.'

  end

end
