module StorageStrategy
    def store(blob_id, data)
      raise NotImplementedError, "Subclasses must implement this method"
    end
  
    def retrieve(blob_id)
      raise NotImplementedError, "Subclasses must implement this method"
    end
end
  