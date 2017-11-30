class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string  :username
      t.string  :avatar
      t.string  :name
      t.string  :code
      t.integer :status, default: 0
      t.string  :type
      t.date    :birthdate
      t.integer :gender
      t.string  :phone
      t.string  :email
      t.string  :password
      t.string  :encrypted_password, default: ""

      t.timestamps
    end

    add_index :users, :username, unique: true
  end
end
