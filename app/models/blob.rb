class Blob < ApplicationRecord
    validates :user_id, presence: true # it's just dummy user_id, as we are not going to have users table for simplicity.
    validates :storage_type, presence: true # s3, local, or FTP
    validates :storage_path, presence: true
    validates :original_filename, presence: true
    validates :content_type, presence: true
    validates :size, presence: true, numericality: { greater_than_or_equal_to: 0 }
  end
  