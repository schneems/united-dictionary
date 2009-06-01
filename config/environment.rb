ENV['RAILS_ENV'] ||= 'development'
RAILS_GEM_VERSION = '2.2.2' unless defined? RAILS_GEM_VERSION

require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  
  config.gem 'mislav-will_paginate', :version => '~> 2.3.5', :lib => 'will_paginate', 
    :source => 'http://gems.github.com'
   # config.gem 'fiveruns_tuneup'
  
  
  config.action_controller.session = {
    :session_key => '_slangasaurus_session',
    :secret      => '6d731843982ba199ffb8aff67c1ec66d0b771d111d948c9fed4c6398c032e10478aa489b9859834d8d3db40db6023a9dc34d85c1a538ced4b521a560477afc50'
  }

  config.load_paths << "#{RAILS_ROOT}/app/sweepers"
  #config.gem 'mbleigh-subdomain-fu', :source => "http://gems.github.com", :lib => "subdomain-fu"

end



Time::DATE_FORMATS[:my_time] = "%B %d, %I:%M %p"




require 'will_paginate'



