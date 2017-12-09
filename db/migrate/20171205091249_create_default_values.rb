class CreateDefaultValues < ActiveRecord::Migration[5.1]
  def change
    create_table :default_values do |t|
      t.string :label
      t.string :name
      t.json   :content

      t.timestamps
    end
  end
end
