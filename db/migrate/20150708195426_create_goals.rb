class CreateGoals < ActiveRecord::Migration
  def change
    create_table :goals do |t|
      t.belongs_to :user, index: true

      ## User Goals
      t.text :be_more_active, :default => '{"name": "Be more active", "checked": false}'
      t.text :lose_weight, :default => '{"name": "Lose weight", "checked": false}'


      t.timestamps null: false
    end
  end
end
