require 'resque/tasks'
require 'resque/scheduler/tasks'
require 'resque-scheduler'

namespace :resque do
  task :setup => :environment do
    Resque.schedule = YAML.load_file(
      Rails.root.join('config', 'static_schedule.yml')
    )
  end
end