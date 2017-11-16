class CreateNotifications < ActiveRecord::Migration[5.1]
  def change
    create_table :notifications do |t|
      t.string :title
      t.text :content
      t.integer :notify_type
      t.datetime :send_time

      t.references :building, index: true, foreign_key: true
      t.references :receiver, index: true, foreign_key: {to_table: :users}

      t.timestamps
    end
  end
end
