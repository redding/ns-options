require 'ns-options/has_options'
require 'ns-options/helper'
require 'ns-options/namespace'
require 'ns-options/namespaces'
require 'ns-options/option'
require 'ns-options/options'
require 'ns-options/proxy'
require 'ns-options/version'

module NsOptions

  def self.included(receiver)
    receiver.send(:include, HasOptions)
  end

end
