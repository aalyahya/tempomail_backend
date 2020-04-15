require 'rails_helper'

RSpec.describe "Web::Homes", type: :request do

  describe "GET /show" do
    it "returns http success" do
      get "/web/home/show"
      expect(response).to have_http_status(:success)
    end
  end

end
