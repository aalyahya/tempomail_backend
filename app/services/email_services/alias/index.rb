# frozen_string_literal: true
# # frozen_string_literal: true
class EmailServices::Alias::Index < EmailServices::Base

  def initialize
    @emails = []
  end

  def call
    current_logger = ActiveRecord::Base.logger
    ActiveRecord::Base.logger = nil

    process!

    ActiveRecord::Base.logger = current_logger
    @emails
  end

  private

    def process!
      url = URI("https://box.inboxizer.com/admin/mail/aliases?format=json")

      https = Net::HTTP.new(url.host, url.port)
      https.use_ssl = true

      request = Net::HTTP::Get.new(url)
      request["Authorization"] = "Basic YWJkdWxsYWhAaW5ib3hpemVyLmNvbTpPbmVAMTUzNjY2"
      response = https.request(request)

      if response.code == '200'
        x = JSON.parse(response.body)

        @emails = x.select { |e| e["domain"] == "inboxizer.com" }[0]["aliases"]\
                    .map { |e| e["address"] if e["forwards_to"].include?('app-client@inboxizer.com') }\
                    .compact

        @emails.each { |email| EmailAddress.find_or_create_by!(email: email) }
      else
        puts "======= Failed! #{response.read_body}"
        []
      end
    end
end
