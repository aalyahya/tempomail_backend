# frozen_string_literal: true
class CreateMessages < ActiveRecord::Migration[6.0]
  def change
    create_table :messages do |t|
      t.integer :seqno, null: false
      t.string :message_id, null: false, index: true
      t.references :email_address, index: true, foreign_key: true, null: true
      t.string :date
      t.string :subject
      t.jsonb :from, array: true
      t.jsonb :sender, array: true
      t.jsonb :reply_to, array: true
      t.jsonb :to, array: true
      t.jsonb :cc, array: true
      t.jsonb :bcc, array: true
      t.string :in_reply_to
      t.string :internal_date
      t.text :rfc822
      t.text :rfc822_header
      t.text :rfc822_text
      t.timestamps null: false
      t.timestamp :deleted_at
    end
  end
end
