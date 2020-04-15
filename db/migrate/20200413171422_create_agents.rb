# frozen_string_literal: true
class CreateAgents < ActiveRecord::Migration[6.0]
  def change
    create_table :agents do |t|
      t.uuid :uuid, default: 'uuid_generate_v4()'
      t.string :player_id
      t.timestamps null: false
      t.timestamp :deleted_at
    end
  end
end
