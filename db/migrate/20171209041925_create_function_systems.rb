class CreateFunctionSystems < ActiveRecord::Migration[5.1]
  def change
    create_table :function_systems do |t|
      t.string :name
      t.string :label
      t.string :description
      t.integer :status, default: 0
      t.json    :extra_content

      t.integer  :parent_id, null: true, index: true
      t.integer  :lft, null: false, index: true
      t.integer  :rgt, null: false, index: true
      t.integer  :depth, null: false, default: 0
      t.integer  :children_count, null: false, default: 0

      t.timestamps
    end
  end
end
