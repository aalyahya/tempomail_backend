# frozen_string_literal: true
class Agent < ApplicationRecord

  # act_as_paranoid

  validates :session_id, presence: true
  validates :session_id, uniqueness: true, if: [:session_id_changed?, :session_id?]

  after_create :claim_email

  private

    def claim_email
      EmailAddress.claim_for!(id)
    end
end
