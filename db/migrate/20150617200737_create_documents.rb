class CreateDocuments < ActiveRecord::Migration
  def change
    create_table :documents do |t|
      t.belongs_to :user, index: true
      t.string :documentID

      t.timestamps null: false
    end
  end
end
