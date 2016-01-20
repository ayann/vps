app_path = File.expand_path(File.join(File.dirname(__FILE__), '../../'))

# listen '127.0.0.1:4000'
listen(3000, backlog: 64) if ENV['RAILS_ENV'] == 'development'
listen File.join(app_path, 'shared/unicorn.sock'), backlog: 64

worker_processes 2

working_directory File.join(app_path, 'current')
pid File.join(app_path, 'shared/unicorn.pid')
stderr_path File.join(app_path, 'current/log/unicorn.log')
stdout_path File.join(app_path, 'current/log/unicorn.log')

# Load the app up before forking.
preload_app true

# Garbage collection settings.
GC.respond_to?(:copy_on_write_friendly=) &&
  GC.copy_on_write_friendly = true

# If using ActiveRecord, disconnect (from the database) before forking.
before_fork do |server, worker|
  defined?(ActiveRecord::Base) &&
    ActiveRecord::Base.connection.disconnect!
end

# After forking, restore your ActiveRecord connection.
after_fork do |server, worker|
  defined?(ActiveRecord::Base) &&
    ActiveRecord::Base.establish_connection
end
