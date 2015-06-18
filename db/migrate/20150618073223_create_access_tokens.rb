class CreateAccessTokens < ActiveRecord::Migration
  def change
    create_table :access_tokens do |t|
      t.belongs_to :user, index: true
      t.string :token

      t.timestamps null: false
    end
  end
end
