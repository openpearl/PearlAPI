# This migration comes from pearl_engine (originally 20150707183010)
class CreatePearlEnginePearlModules < ActiveRecord::Migration
  def change
    create_table :pearl_engine_pearl_modules do |t|
      t.string   :type
      t.integer  :use_count, :default => 0, :null => false
      
      t.timestamps null: false
    end
  end
end
