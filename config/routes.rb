 ActionController::Routing::Routes.draw do |map|

   
   map.signup '/signup', :controller => 'users', :action => 'new'
   map.login  '/login', :controller => 'sessions', :action => 'new'
   map.logout '/logout', :controller => 'sessions', :action => 'destroy'
   map.profile '/profile', :controller => 'users', :action => 'show'
  # map.random '/random', :controller => 'phrases', :action => 'random'
  # map.new_slang '/new_slang', :controller => 'phrases', :action => 'new_slang'
  # map.slang_game '/slang_game', :controller => 'phrases', :action => 'slang_game'
  # map.orphans '/orphans', :controller => 'phrases', :action => 'orphans'
   

   
   map.simple_captcha '/simple_captcha/:action', :controller => 'simple_captcha'
   map.open_id_complete 'session', :controller => "sessions", :action => "create", :requirements => { :method => :get }
   

  map.resources :mugshots
  map.resources :users
  map.resource :sessions
  map.resource :session
  map.resources :phrases


  map.home '', :controller => 'phrases', :action => 'index'

  map.connect '/:action', :controller => 'phrases'
 # map.connect '/:controller/:action'  
  map.connect '/:controller/:action.'  
 # map.connect ':controller/:action/:id'
  map.connect '/:language/:word', :controller => 'phrases', :action => 'show'

  # map.connect ':controller/:action/:id.:format'
end
