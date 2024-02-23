module StorageInitializer
    require_relative 's3_storage'
    require_relative 'local_storage'

    def self.initialize_storage
      case ENV['STORAGE_STRATEGY']
      when 'S3'
        S3Storage.new
      when 'Local'
        LocalStorage.new
      else
        raise "Invalid storage strategy: #{ENV['STORAGE_STRATEGY']}"
      end
    end
  end
  