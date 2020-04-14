# frozen_string_literal: true
# == Schema Information
#
# Table name: messages
#
#  id            :bigint(8)        not null, primary key
#  bcc           :jsonb            is an Array
#  cc            :jsonb            is an Array
#  date          :string
#  email         :string
#  from          :jsonb            is an Array
#  in_reply_to   :jsonb            is an Array
#  internal_date :string
#  reply_to      :jsonb            is an Array
#  rfc822        :text
#  rfc822_header :text
#  rfc822_text   :text
#  sender        :jsonb            is an Array
#  subject       :string
#  to            :jsonb            is an Array
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  message_id    :string
#
class Message < ApplicationRecord
end
