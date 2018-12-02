# README

copying data from sample ftp server
ftpcr = Ftpcr.new(host: 'test.rebex.net', username: 'demo', password: 'password')

ftpcr.save


copying only files
ftpcr.copy_files_with_folders
ftpcr.copy_files_with_folders('source_complete_path')

copying folders with files
ftpcr.copy_files_with_folders
ftpcr.copy_files_with_folders('source_complete_path')
