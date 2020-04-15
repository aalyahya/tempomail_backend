# frozen_string_literal: true
module Delayed
  class Job < ::ActiveRecord::Base
    belongs_to :owner, polymorphic: true
  end
end
