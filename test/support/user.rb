class User
  include NsOptions::Configurable
  configurable(:preferences, 'preferences:user') do
    option :home_url
    option :show_messages,  NsOptions::Option::Boolean, :require => true
    option :font_size,      Integer,                    :default => 12
  end
end