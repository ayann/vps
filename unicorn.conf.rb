app_path = File.expand_path(File.join(File.dirname(__FILE__), '../../'))

# listen '127.0.0.1:4000'
listen(3000, backlog: 64) if ENV['RAILS_ENV'] == 'development'
listen File.join(app_path, 'shared/unicorn.sock'), backlog: 64

worker_processes 2

working_directory File.join(app_path, 'current')
pid File.join(app_path, 'shared/unicorn.pid')
stderr_path File.join(app_path, 'current/log/unicorn.log')
stdout_path File.join(app_path, 'current/log/unicorn.log')
