require './app/jobs/application_job'
class SftpCopyFilesJob < ApplicationJob
  queue_as :default

  def perform(*args)
  	Ftpcr.trigger_copying_all
  end
end
