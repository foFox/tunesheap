# config valid only for Capistrano 3.1
lock '3.2.1'

set :application, 'tunesheap'
set :repo_url, "https://www.github.com/foFox/#{fetch(:application)}.git"
set :deploy_to, "/var/www/#{fetch(:application)}"
set :rvm_ruby_version, '2.1.2'

namespace :host do
  desc "Install Git"
  task :install_git do
    on "ubuntu@54.191.231.205" do
      if not test("[ -f /usr/bin/git ]") then
        sudo "apt-get install git-core git-svn -y"
      end
    end
  end

  desc "Create application directory" 
  task :create_app_directory do
      on "ubuntu@54.191.231.205" do
        if test("[ ! -d /var/www/ ]") then
          sudo "mkdir /var/www"
        end

        if test("[ ! -d /var/www/#{fetch(:application)} ]") then
          sudo "mkdir /var/www/#{fetch(:application)}"
          sudo "chown -R ubuntu:ubuntu /var/www/#{fetch(:application)}"
        end
      end
  end
end

namespace :deploy do
  
  before "deploy:started", "host:install_git"
  after "host:install_git", "host:create_app_directory"

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do

    end
  end

  after :publishing, :restart

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      run "unicorn_rails -c #{fetch(:application)}/config/unicorn.rb -D"  
    end
  end

end


