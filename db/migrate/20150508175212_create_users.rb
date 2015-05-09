class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :name
      t.string :surname
      t.string :email
      t.string :crypted_password
      t.string :role

      t.timestamps null: false
    end
  end

  def self.down
    drop_table :users
  end
end
