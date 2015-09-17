require 'yaml'
require 'mina'

deploy_config = YAML.load(File.open('config/servers.yml'))
set :stages, deploy_config['servers']
set :default_stage, deploy_config['default_server']
set :stages_dir, 'config/servers'

# Global settings
set :user, 'deployer'
set :deploy_to, '<app path>'
set :shared_paths, ['config.prod', 'log', 'run.sh']
set :deploy_tmp, "#{shared_path}/tmp"
set :binary_filename, '<binary filename>'

# i know this is a bit wierd...
require 'mina/multistage'

# We want to leverage rsync but only keeps the main file to upload.
set :rsync_options, %w[
  --rsync-path=<rsync path>
  --progress --partial
  --compress
  --update
  --copy-links
  --recursive --delete --delete-excluded
  --exclude .git*
  --exclude .gitignore
  --exclude /config/***
  --exclude /test/***
  --exclude Gemfile.*
  --exclude *.md
  --exclude /scripts/***
  --exclude deploy
]

task :environment do
end

# We have to put a rsync binary on the server
# since it's not included in the docker image.
task :setup => :environment do
  %w[log config tmp bin].each do |sub_dir|
    queue! %[mkdir -p "#{deploy_to}/#{shared_path}/#{sub_dir}"]
    queue! %[chmod g+rx,u+rwx "#{deploy_to}/#{shared_path}/#{sub_dir}"]
  end

  queue  %[echo "-----> Be sure to edit '#{deploy_to}/#{shared_path}/<config.prod>'."]

  to :after_hook do
    queue! %[scp share/config.prod.sample #{user}@#{domain}:#{deploy_to}/#{shared_path}/config.prod]
    queue! %[scp share/run.sh #{user}@#{domain}:#{deploy_to}/#{shared_path}/]
    queue! %[scp share/rsync #{user}@#{domain}:#{deploy_to}/#{shared_path}/bin/]
  end
end

desc "Deploys the current version to the server."
task :deploy => :environment do
  to :before_hook do
    invoke :'check:binary_exists'
    invoke :'message:welcome'
    invoke :'upload:rsync'
  end
  deploy do

    invoke :'deploy:link_shared_paths'
    invoke :'remote:move'
    invoke :'deploy:cleanup'

    to :launch do
      queue "cd #{deploy_to}/#{current_path}"
      queue "nohup ./run.sh restart >> /dev/null 2>&1 &"
    end
  end
end

namespace :message do
  task :welcome do
    queue %[echo "Deploying to #{domain} ..."]
  end
end

namespace :check do
  task :binary_exists do
    die 42, "#{binary_filename} not found!" unless File.exist? binary_filename
  end
end

namespace :upload do
  desc "Upload the program to tmp dir via rsync"
  task :rsync do
    rsync = %w[rsync]
    rsync.concat settings.rsync_options
    rsync << "./#{binary_filename}"
    rsync << "#{user}@#{domain}:#{deploy_to}/#{deploy_tmp}/"
    queue! rsync.join(' ')
  end

  desc "Upload the program to tmp dir via scp"
  task :scp do
    queue! %[scp -Cr ./#{binary_filename} #{user}@#{domain}:#{deploy_to}/#{deploy_tmp}/]
  end
end

namespace :remote do
  desc "Move the program from tmp dir to working dir."
  task :move do
    queue! %[mv #{deploy_to}/#{deploy_tmp}/#{binary_filename} #{deploy_to}/$build_path/]
  end

  desc "Copy the program from tmp dir to working dir."
  task :copy do
    queue! %[cp #{deploy_to}/#{deploy_tmp}/#{binary_filename} #{deploy_to}/$build_path/]
  end
end
