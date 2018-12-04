module SftpHelper
	def sftp_copy_files(source_folder = '/', options = {})
		return nil unless source_folder.first == '/'
		source_folder += '/' unless source_folder[-1, 1] == '/'
		sftp_save_files(source_folder, default_destination_folder + source_folder, options[:folders])
		sftp_close
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
	def sftp_save_files(source_folder, destination_folder, folders = false)
		FileUtils.mkdir_p(destination_folder) unless Dir.exist?(destination_folder)
		begin
			entries = sftp.dir.entries(source_folder)
		rescue Exception => e
			p "%%%%%%%%%%%%%%%%%%%%"
			p "path => #{source_folder}"
			p e.message
			p "%%%%%%%%%%%%%%%%%%%%"
			return nil
		end
		entries.each do |entry|
			if entry.file?
				save_file_with_sftp(source_folder + entry.name, destination_folder + entry.name)
			elsif folders && entry.name != '.' && entry.name != '..'
				sftp_save_files(source_folder + entry.name + '/', destination_folder + entry.name + '/', true)
			end
		end
	end

	def save_file_with_sftp(source_file, destination_file)
		begin
			if ftpfiles.where(file_name: source_file).blank?
				sftp.download!(source_file, destination_file)
				ftpfiles.create(file_name: source_file)
			end
		rescue Exception => e
			p "%%%%%%%%%%%%%%%%%%%%"
			p "file => #{source_file}"
			p e.message
			p "%%%%%%%%%%%%%%%%%%%%"
		end
	end
end