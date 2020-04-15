# frozen_string_literal: true
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  has_many :jobs, class_name: '::Delayed::Job', as: :owner

  strip_attributes
  englishize_digits

  def self.absolute_class_name
    klass = self

    begin
      klass_name = klass.name
      klass = klass.superclass
    end until klass.name == 'ApplicationRecord'

    klass_name
  end

  private

    def save_with_no_trace
      without_auditing do
        self.record_timestamps = false
        save!(validate: false)
      end
    end
end
