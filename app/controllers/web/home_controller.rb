# frozen_string_literal: true
class Web::HomeController < ApplicationController
  def show
    agent = Agent.find_by(uuid: cookies[:agent_uuid]) if cookies[:agent_uuid]
    agent = Agent.create! if agent.blank?
    cookies[:agent_uuid] = agent.uuid
    render :show, locals: {email_address: agent.email, messages: agent.email.messages.order(:id)}
  end
end
