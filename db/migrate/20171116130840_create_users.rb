class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string  :avatar
      t.string  :name
      t.string  :code
      t.integer :status, default: 0
      t.string  :type
      t.date :birthdate
      t.integer :gender
      t.string :phone
      t.string :phone2
      t.string :email

      t.timestamps
    end
  end
end
