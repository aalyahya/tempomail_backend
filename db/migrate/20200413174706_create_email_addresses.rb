# frozen_string_literal: true
class CreateEmailAddresses < ActiveRecord::Migration[6.0]
  def change
    create_table :email_addresses do |t|
      t.string :email, null: false, size: 64
      t.references :agent, index: true, foreign_key: true, null: true
      t.timestamps null: false
      t.timestamp :locked_at
      t.timestamp :deleted_at
      t.index [:email], unique: true
      t.index [:deleted_at, :email], where: '(deleted_at IS NULL)'
      t.index :locked_at, where: '(locked_at IS NULL)'
    end
  end
end
