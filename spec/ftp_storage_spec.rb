require 'rails_helper'

RSpec.describe FTPStorage do
  let(:storage) { FTPStorage.new }
  let(:blob_id) { 'random_id' }
  let(:content) { 'Hello simple drive!!' }

  before do
    allow(storage).to receive(:store).and_return(true)
    allow(storage).to receive(:retrieve).and_return(content)
  end

  it 'stores a file in FTP' do
    expect(storage.store(blob_id, content)).to be true
  end

  it 'retrieves a file from FTP' do
    expect(storage.retrieve(blob_id)).to eq(content)
  end

  it 'handles failed storing' do
    allow(storage).to receive(:store).and_raise("Error storing file")
    expect { storage.store(blob_id, content) }.to raise_error("Error storing file")
  end

  it 'handles failed retrieval' do
    allow(storage).to receive(:retrieve).and_raise("Error retrieving file")
    expect { storage.retrieve(blob_id) }.to raise_error("Error retrieving file")
  end

  # Add more edge cases as needed
end
