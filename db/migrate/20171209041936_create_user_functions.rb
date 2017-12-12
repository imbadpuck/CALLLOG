class CreateUserFunctions < ActiveRecord::Migration[5.1]
  def change
    create_table :user_functions do |t|
      t.references :user, index: true, foreign_key: true
      t.references :group, index: true, foreign_key: true
      t.references :function_system, index: true, foreign_key: true

      t.timestamps
    end
  end
end
