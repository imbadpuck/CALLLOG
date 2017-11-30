class CreateSubComments < ActiveRecord::Migration[5.1]
  def change
    create_table :sub_comments do |t|
      t.text       :content
      t.references :comment, index: true, foreign_key: true, null: false
      t.references :user, index: true, foreign_key: true
      t.integer    :type
      t.string     :note

      t.timestamps
    end
  end
end
