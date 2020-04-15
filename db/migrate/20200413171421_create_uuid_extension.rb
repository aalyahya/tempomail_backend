# frozen_string_literal: true
class CreateUuidExtension < ActiveRecord::Migration[6.0]
  def change
    enable_extension "uuid-ossp"
    enable_extension "pgcrypto"
  end
end
