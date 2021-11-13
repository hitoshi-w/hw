# config valid for current version and patch releases of Capistrano
lock "~> 3.16.0"

# capistrano
set :application, "hw"
set :repo_url, "git@github.com:hitoshi-w/hw.git"
set :user, "deploy"
set :deploy_to, "/var/www/hw"
set :deploy_via, :remote_cache
set :format, :airbrussh
set :format_options, truncate: false
set :pty, true
set :keep_releases, 2

# capistrano-puma
# active_recordを使用するのでtrueに設定
set :puma_init_active_record, true
set :puma_preload_app, true
set :puma_access_log, "#{release_path}/log/puma_access.log"
set :puma_error_log, "#{release_path}/log/puma_error.log"

# capstrano-rbenv
# rbenv のインストール先を/usr/local/rbenvに設定
set :rbenv_type, :system
# ruby-versionからrubyのバージョンを設定
set :rbenv_ruby, File.read('.ruby-version').strip
set :rbenv_prefix, "RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} #{fetch(:rbenv_path)}/bin/rbenv exec"
set :rbenv_map_bins, %w{rake gem bundle ruby rails}

# capistrano-rails
append :linked_dirs,
       'log',
       'tmp/pids',
       'tmp/cache',
       'tmp/sockets',
       'vendor/bundle',
       'public/system',
       'node_modules'

append :linked_files, '.env'

namespace :puma do
  desc 'Create Directories for Puma Pids and Socket'
  task :make_dirs do
    on roles(:app) do
      execute "mkdir #{shared_path}/tmp/sockets -p"
      execute "mkdir #{shared_path}/tmp/pids -p"
    end
  end
  before :start, :make_dirs
end

namespace :deploy do
  desc 'Make sure local git is in sync with remote.'
  task :check_revision do
    on roles(:app) do
      unless `git rev-parse HEAD` == `git rev-parse origin/master`
      end
    end
  end

  desc 'Initial deploy'
  task :initial do
    on roles(:app) do
      before 'deploy:restart', 'puma:start'
      invoke 'deploy'
    end
  end

  #  サーバー数が多い場合、例えば git pull などが同時に実行されるとホスティングサーバーに負荷がかかります。また、デプロイ後のプロセス再起動を全ホストで一斉に行うとダウンタイムが発生するため 1 ホストずつプロセス再起動 (rolling restarts) するのが好ましいです。これを実現するためにはin: :sequenceを用いて各サーバーに順番にログインするようにする
  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      invoke 'puma:restart'
    end
  end

  desc 'Create Database'
  task :db_create do
    on roles(:db) do
      with rails_env: fetch(:rails_env) do
        within current_path do
          execute :bundle, :exec, :rake, 'db:create'
        end
      end
    end
  end

  desc 'Reset database'
  task :db_reset do
    on roles(:db) do
      with rails_env: fetch(:rails_env) do
        within release_path do
          execute :bundle, :exec, :rake, 'db:migrate:reset'
        end
      end
    end
  end

  desc 'Migrate database'
  task :db_migrate do
    on roles(:db) do
      with rails_env: fetch(:rails_env) do
        within release_path do
          execute :bundle, :exec, :rake, 'db:migrate'
        end
      end
    end
  end

  desc 'reload the database with seed data'
  task :seed do
    on roles(:db) do
      with rails_env: fetch(:rails_env) do
        within release_path do
          execute :bundle, :exec, :rake, 'db:seed'
        end
      end
    end
  end

  before :starting,     :check_revision
  after  :finishing,    :compile_assets
  after  :finishing,    :cleanup
end
