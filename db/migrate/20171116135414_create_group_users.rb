class CreateGroupUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :group_users do |t|
      t.string     :regency
      t.references :user, index: true, foreign_key: true, null: false
      t.references :group, index: true, foreign_key: true, null: false

      t.timestamps
    end
  end
end
