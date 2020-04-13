# frozen_string_literal: true
class RenameLockedByToAgentId < ActiveRecord::Migration[6.0]
  def change
    remove_column :email_addresses, :locked_by, :bigint
    add_reference :email_addresses, :agent, index: true, foreign_key: true, null: true
  end
end
