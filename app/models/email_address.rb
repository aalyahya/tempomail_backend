# frozen_string_literal: true

# == Schema Information
#
# Table name: email_addresses
#
#  id         :bigint(8)        not null, primary key
#  deleted_at :datetime
#  email      :string           not null
#  locked_at  :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  agent_id   :bigint(8)
#
# Indexes
#
#  index_email_addresses_on_agent_id              (agent_id)
#  index_email_addresses_on_deleted_at_and_email  (deleted_at,email) WHERE (deleted_at IS NULL)
#  index_email_addresses_on_email                 (email) UNIQUE
#  index_email_addresses_on_locked_at             (locked_at) WHERE (locked_at IS NULL)
#
# Foreign Keys
#
#  fk_rails_...  (agent_id => agents.id)
#
class EmailAddress < ApplicationRecord

  # act_as_paranoid

  scope :available, -> { where(locked_by: nil) }

  validates :email, presence: true
  validates :email, uniqueness: true, if: [:email_changed?, :email?]

  def self.claim_for!(agent_id)
    email = available.shuffle.first!
    email.claim_for! agent_id
  end

  def available?
    !agent_id?
  end

  def not_available?
    !available?
  end

  private

    def claim_for!(agent_id)
      raise ActiveRecord::RecordInvalid if not_available?

      update!(agent_id: agent_id, locked_at: Time.new)
      email
    end
end
