class CreateGoals < ActiveRecord::Migration
  def change
    create_table :goals do |t|
      t.belongs_to :user, index: true

      ## User Goals
      t.boolean :be_more_active, :default => false
      t.boolean :lose_weight, :default => false

      t.timestamps null: false
    end
  end
end
