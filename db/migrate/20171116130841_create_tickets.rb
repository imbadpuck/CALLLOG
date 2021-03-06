class CreateTickets < ActiveRecord::Migration[5.1]
  def change
    create_table :tickets do |t|
      t.string   :title
      t.text     :content
      t.integer  :status
      t.integer  :priority
      t.datetime :resolved_at
      t.datetime :closed_at
      t.string   :attachments, array: true, default: "[]"
      t.date     :begin_date, :default => Time.zone.now
      t.datetime :deadline
      t.integer  :comment_count, :default => 0
      t.integer  :rating, :default => 0

      t.integer  :parent_id, null: true, index: true
      t.integer  :lft, null: false, index: true
      t.integer  :rgt, null: false, index: true
      t.integer  :depth, null: false, default: 0
      t.integer  :children_count, null: false, default: 0

      t.references :creator, index: true, foreign_key: {to_table: :users}
      t.timestamps
    end
  end
end
