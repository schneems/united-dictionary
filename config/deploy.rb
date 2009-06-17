set :user, "snowmaninthesun"
set :application, "uniteddictionary.com"
set :app_folder, "current"
set :scm, 'git'
set :repository, "git@github.com:snowmaninthesun/united-dictionary.git"
set :deploy_via, :remote_cache
set :git_enable_submodules, 1 # if you have vendored rails
set :branch, 'master'
set :git_shallow_clone, 1
set :scm_verbose, true



role :web, application
role :app, application
role :db,  application, :primary => true


set :deploy_to, "/home/#{user}/#{application}/#{app_folder}"
set :use_sudo, false
set :checkout, "export"
set :scm_verbose, true

desc "Fix permissions and set environment after code update."
task :after_update_code, :roles => [:app, :db, :web] do
  # set permissions
  run "chmod +x #{release_path}/script/process/reaper"
  run "chmod +x #{release_path}/script/process/spawner"
  run "chmod 755 #{release_path}/script/spin"
  run "chmod 755 #{release_path}/public/dispatch.*"
  # switch to production mode in config/environment.rb
  run "sed 's/# ENV\\[/ENV\\[/g' #{release_path}/config/environment.rb > #{release_path}/config/environment.temp"
  run "mv #{release_path}/config/environment.temp #{release_path}/config/environment.rb"
  # switch to fastcgi dispatcher in public/.htaccess
  run "sed 's/RewriteRule \^\(\.\*\)\$ dispatch\.cgi/RewriteRule ^(.*)$ dispatch.fcgi/g' #{release_path}/public/.htaccess > #{release_path}/public/.htaccess-temp"
  run "mv #{release_path}/public/.htaccess-temp #{release_path}/public/.htaccess"
end

desc "Start/restart server after deployment."
task :restart_web_server, :roles => :web do
  run "touch #{deploy_to}/current/public/dispatch.fcgi"
end

after "deploy:start", :restart_web_server
after "deploy:restart", :restart_web_server


