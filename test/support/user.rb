require 'ns-options'
require 'ns-options/boolean'

class User

  # mixin using the specific HasOptions variant
  include NsOptions

  options(:preferences) do
    option :home_url
    option :show_messages,  NsOptions::Boolean, :require => true
    option :font_size,      Integer,            :default => 12

    namespace :view do
      option :color
    end
  end

  def preferences_key
    "user_#{self.object_id}"
  end

end
