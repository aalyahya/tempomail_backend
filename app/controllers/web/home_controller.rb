# frozen_string_literal: true
class Web::HomeController < Web::Base
  def show
    cookies[:agent_uuid] ||= SecureRandom.uuid
    agent = Agent.find_or_create_by!(uuid: cookies[:agent_uuid])
    @email = agent.email
    cookies[:agent_uuid] = agent.uuid
  end
end
