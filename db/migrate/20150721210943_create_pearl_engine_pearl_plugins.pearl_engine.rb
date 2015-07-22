# This migration comes from pearl_engine (originally 20150721205535)
class CreatePearlEnginePearlPlugins < ActiveRecord::Migration
  def change
    create_table :pearl_engine_pearl_plugins do |t|
      t.string   :type
      
      t.timestamps null: false
    end
  end
end
