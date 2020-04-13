# frozen_string_literal: true
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
