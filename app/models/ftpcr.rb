require 'net/ftp'
class Ftpcr < ApplicationRecord
	has_many :ftpfiles
	 validates_uniqueness_of :host, scope: :username
	def copy_only_files_from_ftp_server(source_folder = '/')
		save_files_with_ftp(source_folder, default_destination_folder)
		ftp.close
	end

	def copy_only_files_from_sftp_server(source_folder = '/')
		save_files_with_sftp(source_folder, default_destination_folder)
		sftp_close
	end

	def copy_files_with_folders(source_folder = '/')
		ftp.chdir(source_folder)
		save_files(source_folder, default_destination_folder + source_folder )
		ftp.ls.each do |entry|
			if entry.split(/\s+/)[2] == '<DIR>'
				copy_files_with_folders(source_folder + (source_folder == '/' ? '' : '/') + entry.split(/\s+/)[3])
			end
		end
		ftp.close
	end

	private


	def default_destination_folder
		Rails.root.join('public', 'ftp').to_s
	end

	def sftp
		@session ||= Net::SSH.start(self.host, self.username, {password: self.password, port: 22})
		@sftp ||= Net::SFTP::Session.new(@session)
		@sftp.connect! unless @sftp.open?
		@sftp
	end
	def sftp_close
		@sftp.close_channel unless @sftp.nil? # Close SFTP
  	@session.close unless @session.nil?
	end
	def save_files_with_sftp(source_folder, destination_folder)
		FileUtils.mkdir_p(destination_folder) unless Dir.exist?(destination_folder)
		sftp.dir.entries(source_folder).each do |entry|
			destination_file = destination_folder + '/' + entry.name
			if entry.file? && ftpfiles.where(file_name: source_folder + entry.name).blank?
				sftp.download!(source_folder + entry.name, destination_file)
				ftpfiles.create(file_name: source_folder + entry.name)
			end
		end

	end

	def ftp
		@ftp_obj.noop rescue @ftp_obj = nil
		@ftp_obj ||= Net::FTP.new(self.host, self.username, self.password)
	end
	def save_files_with_ftp(source_folder, destination_folder)
		ftp.chdir(source_folder)
		FileUtils.mkdir_p(destination_folder) unless Dir.exist?(destination_folder)
		ftp.nlst('*').each do |file_name|
			destination_file = destination_folder + file_name
			if ftpfiles.where(file_name: destination_file).blank?
				ftp.getbinaryfile(file_name, destination_file)
				ftpfiles.create(file_name: destination_file)
			end
		end

	end
end
