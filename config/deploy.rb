# For complete deployment instructions, see the following support guide:
# http://www.engineyard.com/support/guides/deploying_your_application_with_capistrano

require "eycap/recipes"
require 'reconciler'

# =================================================================================================
# ENGINE YARD REQUIRED VARIABLES
# =================================================================================================
# You must always specify the application and repository for every recipe. The repository must be
# the URL of the repository you want this recipe to correspond to. The :deploy_to variable must be
# the root of the application.

set :keep_releases,       5
set :application,         "reconciler"
set :user,                "someone"
set :password,            "secret"
set :deploy_to,           "/data/#{application}"
set :runner,              "someone"
set :repository,          "git@github.com:danielberlinger/reconciler.git"
set :scm,                 :git
# This will execute the Git revision parsing on the *remote* server rather than locally
set :real_revision,       lambda { source.query_revision(revision) { |cmd| capture(cmd) } }
set :dbuser,              "someone_db"
set :dbpass,              "secret"
set :git_enable_submodules,1
ssh_options[:paranoid] = false
#set :branch, "some_specific_branch"

# =================================================================================================
# ROLES
# =================================================================================================
# You can define any number of roles, each of which contains any number of machines. Roles might
# include such things as :web, or :app, or :db, defining what the purpose of each machine is. You
# can also specify options that can be used to single out a specific subset of boxes in a
# particular role, like :primary => true.

task :production do  
  role :app, "127.0.0.1"
  set :recon_env, "production"
  set :environment_database, defer { production_database }
  set :environment_dbhost, defer { production_dbhost }
  
  r = reconcile(ENV['RECONCILER_ENV'] || 'production')
  r.run_all
end

task :dev_run_all do  
  role :app, "localhost"
  set :environment_database, defer { production_database }
  set :environment_dbhost, defer { production_dbhost }
  
  r = reconcile(ENV['RECONCILER_ENV'] || 'development')
  r.run_all
end

#cap dev_stats STAT=blogs
task :dev_stats do  
  role :app, "localhost"
  set :environment_database, defer { production_database }
  set :environment_dbhost, defer { production_dbhost }
  r = reconcile(ENV['RECONCILER_ENV'] || 'development')
  stat_setting = ENV['STAT'].to_sym unless ENV['STAT'].nil?
  r.stats( stat_setting || :all)
end

task :dev_clean do
  role :app, "localhost"
  set :environment_database, defer { production_database }
  set :environment_dbhost, defer { production_dbhost }
  r = reconcile(ENV['RECONCILER_ENV'] || 'development')
  r.empty_all_stats
end

def reconcile(env)
  r = Reconcile.new(env)
end