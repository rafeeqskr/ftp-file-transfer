require 'net/ftp'
class Ftpcr < ApplicationRecord
	has_many :ftpfiles
	def copy_only_files(source_folder = '/')
		save_files(source_folder, default_destination_folder)
		ftp.close
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
	def ftp
		@ftp_obj.noop rescue @ftp_obj = nil
		@ftp_obj ||= Net::FTP.new(self.host, self.username, self.password)
	end
	def save_files(source_folder, destination_folder)
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

