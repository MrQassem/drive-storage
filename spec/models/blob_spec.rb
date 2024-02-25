require 'rails_helper'

RSpec.describe Blob, type: :model do
  it 'is valid with valid attributes' do
    blob = Blob.new(
        blob_id: "blob_id", 
        user_id: 1, 
        storage_type: 's3',
        storage_path: 'path/to/data',
        content_type: 'application/base64',
        size: Base64.strict_decode64('SGVsbG8gU2ltcGxlIFN0b3JhZ2UgV29ybGQh').bytesize

        )
    expect(blob).to be_valid
  end
end
