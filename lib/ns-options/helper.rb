require 'ns-options/helper/advisor'

module NsOptions
  module Helper
    module_function

    def advisor(namespace=nil)
      NsOptions::Helper::Advisor.new(namespace)
    end
  end
end
