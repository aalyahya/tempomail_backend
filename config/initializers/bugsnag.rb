# frozen_string_literal: true
Bugsnag.configure do |config|
  config.api_key = "d7095262efae56870f63b048936f5057"
  config.release_stage = Rails.env.to_s
  config.notify_release_stages = %w(staging production)
end
