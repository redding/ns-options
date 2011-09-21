class User
  include NsOptions::Configurable
  configurable(:preferences, 'user-preferences') do
    option :home_url
    option :show_messages,  NsOptions::Option::Boolean, :require => true
    option :font_size,      Integer,                    :default => 12
  end

  def preferences_key
    "user_#{self.object_id}"
  end

end