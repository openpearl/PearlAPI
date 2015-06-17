class CreateBlobs < ActiveRecord::Migration
  def change
    create_table :blobs do |t|
      t.belongs_to :user, index: true
      t.string :blobID

      t.timestamps null: false
    end
  end
end
