require 'net/ftp'

class FTPStorage
  include StorageStrategy

    def initialize
        @host = ENV['FTP_HOST']
        @username = ENV['FTP_USER_NAME']
        @password = ENV['FTP_USER_PASS']
        @base_directory = ENV['FTP_USER_HOME']
    end


    def store(blob_id, data)
        Net::FTP.open(@host, @username, @password) do |ftp|
            puts "Connected to FTP server #{@host}"
            # Split the blob_id to get the directory and filename
            path_parts = blob_id.split('/')
            filename = path_parts.pop
            directory = File.join('', *path_parts)
            puts 'directory'
            puts directory
            puts 'filename'
            puts filename
            create_directory(ftp, directory)
            # Change to the directory where the file will be stored
            ftp.chdir(directory)
            # Store the file
            ftp.storbinary("STOR #{filename}", StringIO.new(Base64.decode64(data)), 1024)
            puts "Stored file #{filename} in #{directory}"
        end
            rescue => e
                puts "Error storing file: #{e.message} to FTP"
    end
      
    def retrieve(blob_id)
        Net::FTP.open(@host, @username, @password) do |ftp|
            puts "Connected to FTP server #{@host}"
            # Split the blob_id to get the directory and filename
            path_parts = blob_id.split('/')
            filename = path_parts.pop
            directory = File.join('', *path_parts)
            puts 'directory'
            puts directory
            puts 'filename'
            puts filename
            ftp.chdir(directory)
            # Retrieve the file
            file_content = ftp.getbinaryfile(filename, nil)
            puts "Retrieved file #{filename} from #{directory}"
            return file_content
        end
        
        rescue => e
            puts "Error retrieving file: #{e.message}"
        return nil
    end
  
  private
    def create_directory(ftp, base_directory)
        begin 
            ftp.chdir(base_directory)
        rescue => e
            parent_dir = File.dirname(base_directory)
            create_directory(ftp, parent_dir) unless parent_dir == base_directory
            ftp.mkdir(base_directory)
            ftp.chdir(base_directory)
        end
    end
end
