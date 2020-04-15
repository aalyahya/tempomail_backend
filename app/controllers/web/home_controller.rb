# frozen_string_literal: true
class Web::HomeController < ApplicationController
  def show
    logger.info cookies[:agent_uuid]
    cookies[:agent_uuid] ||= SecureRandom.uuid
    logger.info cookies[:agent_uuid]
    agent = Agent.find_or_create_by!(uuid: cookies[:agent_uuid])
    @email = agent.email
    cookies[:agent_uuid] = agent.uuid
    logger.info cookies[:agent_uuid]
  end
end
