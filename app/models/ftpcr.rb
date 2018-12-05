require 'net/ftp'
class Ftpcr < ApplicationRecord
	include SftpHelper
	include FtpHelper
	has_many :ftpfiles, dependent: :destroy
	validates_uniqueness_of :host, scope: :username
	
	def default_destination_folder
		Rails.root.join('public', 'ftp', host.gsub(/[^0-9A-Z]/i, '_')).to_s
	end
	def self.trigger_copying_all
		self.all.each{|ftpcr| ftpcr.sftp_copy_files}
	end
end
