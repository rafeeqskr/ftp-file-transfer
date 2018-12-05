require 'resque/tasks'
require 'resque/scheduler/tasks'
require 'resque-scheduler'
require 'active_scheduler'

namespace :resque do
	task :setup => :environment do
		yaml_schedule    = YAML.load_file(Rails.root.join('config', 'static_schedule.yml')) || {}
		wrapped_schedule = ActiveScheduler::ResqueWrapper.wrap yaml_schedule
		Resque.schedule  = wrapped_schedule
	end
end