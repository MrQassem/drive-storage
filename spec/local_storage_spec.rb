require 'rails_helper'

RSpec.describe LocalStorage do
  let(:storage) { described_class.new }
  let(:file_path) { 'test_file.txt' }
  let(:content) { 'Hello simple drive!!' }
  let(:binary_content) { File.binread(Rails.root.join('spec/sample_image.jpg')) }
  let(:long_file_path) { 'a' * 255 + '.txt' } # Assuming a maximum file name length of 255 characters

  before do
    FileUtils.mkdir_p(ENV['STORAGE_PATH'])
  end

  after do
    FileUtils.rm_rf(ENV['STORAGE_PATH'])
  end

  describe '#store' do
    it 'stores a file with empty content' do
      storage.store(file_path, '')
      expect(File.read(File.join(ENV['STORAGE_PATH'], file_path))).to eq('')
    end

    it 'stores a file with nil content' do
      storage.store(file_path, nil)
      expect(File.read(File.join(ENV['STORAGE_PATH'], file_path))).to eq('')
    end

    it 'creates nested directories as needed' do
      nested_path = 'nested/dir/test_file.txt'
      storage.store(nested_path, content)
      expect(File.exist?(File.join(ENV['STORAGE_PATH'], nested_path))).to be true
    end

    it 'handles very long file names' do
      expect { storage.store(long_file_path, content) }.to raise_error(Errno::ENAMETOOLONG)
    end
    
    it 'stores binary data' do
      binary_path = 'sample_image.png'
      storage.store(binary_path, binary_content)
      expect(File.binread(File.join(ENV['STORAGE_PATH'], binary_path))).to eq(binary_content)
    end
  end

  describe '#retrieve' do
    it 'returns nil for a non-existent file' do
      expect(storage.retrieve('non_existent_file.txt')).to be_nil
    end
  end
end
