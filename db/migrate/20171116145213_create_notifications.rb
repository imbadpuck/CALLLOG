class CreateNotifications < ActiveRecord::Migration[5.1]
  def change
    create_table :notifications do |t|
      t.string   :title
      t.json     :content
      t.integer  :notify_type
      t.integer  :status, default: 0

      t.references :receiver, index: true, foreign_key: {to_table: :users}
      t.references :ticket, index: true, foreign_key: true

      t.timestamps
    end
  end
end
