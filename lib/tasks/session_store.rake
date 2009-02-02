file 'config/initializers/session_store.rb' do
  path = File.join(RAILS_ROOT, 'config', 'initializers', 'session_store.rb')
  File.open(path, 'w') do |f|
    f.write <<"EOD"
# This file was generated by 'rake config/initializers/session_store.rb',
# and should not be made visible to public.  Do not check it into github!
# If you have a load-balancing Mephisto cluster, you will need to use the
# same version of this file on each machine.  And be sure to restart your
# server when you modify this file.

# Your secret key for verifying cookie session data integrity.  If you
# change this key, all old sessions will become invalid!  Make sure the
# secret is at least 30 characters and all random, no regular words or
# you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :session_key => '_mephisto_session_2',
  :secret      => '#{ActiveSupport::SecureRandom.hex(40)}'
}
EOD
  end
end
