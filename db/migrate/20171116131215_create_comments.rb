class CreateComments < ActiveRecord::Migration[5.1]
  def change
    create_table :comments do |t|
      t.text    :content
      t.string  :note
      t.string  :attachments, array: true, default: "[]"

      t.references :user, index: true, foreign_key: true
      t.references :ticket, index: true, foreign_key: true
      t.timestamps
    end
  end
end
