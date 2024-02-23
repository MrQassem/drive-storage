class CreateBlobs < ActiveRecord::Migration[5.2]
  def change
    create_table :blobs do |t|
      t.string :blob_id, null: false
      t.string :user_id, null: false
      t.string :storage_type, null: false
      t.string :storage_path, null: false
      t.string :original_filename, null: true
      t.string :content_type, null: false
      t.integer :size, null: false
      t.timestamps
    end
    add_index :blobs, [:user_id, :blob_id], unique: true, name: 'index_blobs_on_user_id_and_blob_id'
  end
end
