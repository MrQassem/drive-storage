class LocalStorage
    include StorageStrategy
  
    def initialize
        # either use the storage path provided in .env, or use 'storage' directory in the root of the project.
        @storage_path = ENV['STORAGE_PATH'] || Rails.root.join('storage')
    end
  
    def store(path, data)
        begin

            # Construct the full storage path
            full_path = File.join(@storage_path, path)

            # Create the directory path if it doesn't exist
            FileUtils.mkdir_p(File.dirname(full_path))

            # Store the file
            File.open(full_path, 'wb') do |file|
            file.write(data)
            puts "File written to #{full_path}"  # Debugging output
            puts "File exists? #{File.exist?(full_path)}"  # Debugging output
        rescue => e
            puts "Error writing file: #{e.message}"  # Debugging output
        end
  
        end
    end
  
    def retrieve(path)
        # Construct the full storage path
        full_path = File.join(@storage_path, path)
        return nil unless File.exist?(full_path)
        File.read(full_path)
    end
  end
  