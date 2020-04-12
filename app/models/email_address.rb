class EmailAddress < ApplicationRecord
  validates :email, presence: true
  validates :email, uniqueness: true, if: [:email_changed?, :email?]
end
