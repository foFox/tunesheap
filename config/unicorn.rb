worker_processes Integer(ENV["WEB_CONCURRENCY"] || 3)
timeout 15
preload_app true

working_directory "/var/www/tunesheap/current"
stderr_path "/var/www/tunesheap/current/log/unicorn_err.log"
stdout_path "/var/www/tunesheap/current/log/unicorn_out.log"
pid "/var/www/tunesheap/current/pids/unicorn.pid"
listen "/tmp/unicorn.tunesheap.sock"


before_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn master intercepting TERM and sending myself QUIT instead'
    Process.kill 'QUIT', Process.pid
  end

  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!
end

after_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn worker intercepting TERM and doing nothing. Wait for master to send QUIT'
  end

  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection
end

before_exec do |server| 
  ENV["BUNDLE_GEMFILE"] = "/var/www/tunesheap/current/Gemfile" 
end