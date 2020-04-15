# frozen_string_literal: true

# == Schema Information
#
# Table name: email_addresses
#
#  id         :bigint(8)        not null, primary key
#  deleted_at :datetime
#  email      :string           not null
#  expire_at  :datetime
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
  has_many :messages

  acts_as_paranoid

  scope :available, -> { where(agent_id: nil) }
  scope :agent, -> (agent_id) { where(agent_id: agent_id) }

  validates :email, presence: true
  validates :email, uniqueness: true, if: [:email_changed?, :email?]

  def self.claim_for!(agent_id)
    email = available.first!
    email.send(:claim_for!, agent_id)
  end

  def available?
    !agent_id?
  end

  def not_available?
    !available?
  end

  def read_only?
    Time.new > locked_at + 1.hour
  end

  private

    def claim_for!(agent_id)
      raise ActiveRecord::RecordInvalid if not_available?

      self.agent_id = agent_id
      self.locked_at = Time.new
      self.expire_at = locked_at + 1.hour
      save!

      self
    end
end
