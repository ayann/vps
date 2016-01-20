require 'mina/bundler'
require 'mina/rails'
require 'mina/git'

# Basic settings:
#   domain       - The hostname to SSH to.
#   deploy_to    - Path to deploy into.
#   repository   - Git repo to clone from. (needed by mina/git)
#   branch       - Branch name to deploy. (needed by mina/git)

set :user, 'rails'
set :branch, 'master'
set :service, 'unicorn'
set :domain, 'foobar.com'
set :app_name, 'projectx'
set :deploy_to, "/home/#{user}/#{app_name}"
set :repository, 'git@github.com:example/rails.git'

# Manually create these paths in shared/ (eg: shared/config/database.yml) in your server.
# They will be linked in the 'deploy:link_shared_paths' step.
set :shared_paths, ['config/database.yml', 'config/secrets.yml', 'log']

# Optional settings:
#   set :user, 'foobar'    # Username in the server to SSH to.
#   set :port, '30000'     # SSH port number.
#   set :forward_agent, true     # SSH forward_agent.

# This task is the environment that is loaded for most commands, such as
# `mina deploy` or `mina rake`.
task :environment do
  ruby_version = File.read('.ruby-version').strip
  ruby_gemset  = File.read('.ruby-gemset').strip
  raise "Couldn't determine Ruby version: Do you have a file .ruby-version in your project root?" if ruby_version.empty?
  queue %{
    source /home/#{user}/.rvm/scripts/rvm
    rvm use #{ruby_version}@#{ruby_gemset} || exit 1
  }
end

task :setup => :environment do
  queue! %[mkdir -p "#{deploy_to}/#{shared_path}/log"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/#{shared_path}/log"]

  queue! %[mkdir -p "#{deploy_to}/#{shared_path}/config"]

  # Add the repository server to .ssh/known_hosts
  if repository
    repo_host = repository.split(%r{@|://}).last.split(%r{:|\/}).first
    repo_port = /:([0-9]+)/.match(repository) && /:([0-9]+)/.match(repository)[1] || '22'

    queue! %[
      if ! ssh-keygen -H  -F #{repo_host} &>/dev/null; then
        ssh-keyscan -t rsa -p #{repo_port} -H #{repo_host} >> ~/.ssh/known_hosts
      fi
    ]
  end

  # Create database.yml for Postgres if it doesn't exist
  path_database_yml = "#{deploy_to}/#{shared_path}/config/database.yml"
  database_yml = %[production:
  database: rails-demo
  adapter: postgresql
  pool: 5
  timeout: 5000]
  queue! %[ test -e #{path_database_yml} || echo "#{database_yml}" > #{path_database_yml} ]

  # Create secrets.yml if it doesn't exist
  path_secrets_yml = "#{deploy_to}/#{shared_path}/config/secrets.yml"
  secret =
  secrets_yml = %[production:
  secret_key_base:
    #{`rake secret`.strip}]
  queue! %[ test -e #{path_secrets_yml} || echo "#{secrets_yml}" > #{path_secrets_yml} ]

  queue! %[chmod g+rx,u+rwx,o-rwx "#{deploy_to}/#{shared_path}/config"]

end

desc "Deploys the current version to the server."
task :deploy => :environment do
  to :before_hook do
    # Put things to run locally before ssh
  end
  deploy do
    # Put things that will set up an empty directory into a fully set-up
    # instance of your project.
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'rails:db_migrate'
    invoke :'rails:assets_precompile'
    invoke :'deploy:cleanup'

    to :launch do
      queue "mkdir -p #{deploy_to}/#{current_path}/tmp/"
      queue "sudo service #{service} restart"
    end
  end
end

# For help in making your deploy script, see the Mina documentation:
#
#  - http://nadarei.co/mina
#  - http://nadarei.co/mina/tasks
#  - http://nadarei.co/mina/settings
#  - http://nadarei.co/mina/helpers
