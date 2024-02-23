class LocalStorage
    include StorageStrategy
  
    def initialize
        # either use the storage path provided in .env, or use 'storage' directory in the root of the project.
        @storage_path = ENV['STORAGE_PATH'] || Rails.root.join('storage')
    end
  
    def store(path, data)
        # Construct the full storage path
        full_path = File.join(@storage_path, path)

        # Create the directory path if it doesn't exist
        FileUtils.mkdir_p(File.dirname(full_path))

        # Store the file
        File.open(full_path, 'wb') do |file|
        file.write(data)
        end
    end
  
    def retrieve(path)
        # Construct the full storage path
        full_path = File.join(@storage_path, path)

        File.read(path)
    end
  end
  