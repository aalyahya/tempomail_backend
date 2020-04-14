# frozen_string_literal: true
class CreateMessages < ActiveRecord::Migration[6.0]
  def change
    create_table :messages do |t|
      t.integer :seqno, null: false
      t.string :message_id, null: false
      t.string :email
      t.string :date
      t.string :subject
      t.jsonb :from, array: true
      t.jsonb :sender, array: true
      t.jsonb :reply_to, array: true
      t.jsonb :to, array: true
      t.jsonb :cc, array: true
      t.jsonb :bcc, array: true
      t.jsonb :in_reply_to, array: true
      t.string :internal_date
      t.text :rfc822
      t.text :rfc822_header
      t.text :rfc822_text
      t.timestamps null: false
    end
  end
end
