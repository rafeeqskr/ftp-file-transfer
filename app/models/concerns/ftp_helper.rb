module FtpHelper
	def ftp_copy_files(source_folder = '/')
		return nil unless source_folder.first == '/'
		source_folder += '/' unless source_folder[-1, 1] == '/'
		ftp_save_files(source_folder, default_destination_folder + source_folder)
		ftp.close
	end
	def ftp_copy_files_with_folders(source_folder = '/')
		ftp.chdir(source_folder)
		save_files(source_folder, default_destination_folder + source_folder )
		ftp.ls.each do |entry|
			if entry.split(/\s+/)[2] == '<DIR>'
				copy_files_with_folders(source_folder + (source_folder == '/' ? '' : '/') + entry.split(/\s+/)[3])
			end
		end
		ftp.close
	end
	def ftp
		@ftp_obj.noop rescue @ftp_obj = nil
		@ftp_obj ||= Net::FTP.new(self.host, self.username, self.password)
	end
	def ftp_save_files(source_folder, destination_folder)
		ftp.chdir(source_folder)
		FileUtils.mkdir_p(destination_folder) unless Dir.exist?(destination_folder)
		ftp.nlst('*').each do |file_name|
			destination_file = destination_folder + file_name
			if ftpfiles.where(file_name: destination_file).blank?
				begin
					ftp.getbinaryfile(file_name, destination_file)
					ftpfiles.create(file_name: destination_file)
				rescue Exception => e
					p "%%%%%%%%%%%%%%%%%%%%"
					p "file => #{file_name}"
					p e.message
					p "%%%%%%%%%%%%%%%%%%%%"
				end
			end
		end
	end
end