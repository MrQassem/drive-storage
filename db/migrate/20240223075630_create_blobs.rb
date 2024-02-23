class CreateBlobs < ActiveRecord::Migration[5.2]
  def change
    create_table :blobs do |t|
      t.string :user_id, null: false
      t.string :storage_type, null: false
      t.string :storage_path, null: false
      t.string :original_filename, null: false
      t.string :content_type, null: false
      t.integer :size, null: false
      t.timestamps
    end
    add_index :blobs, :user_id, unique: true
  end
end
