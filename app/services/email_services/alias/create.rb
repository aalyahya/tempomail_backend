# # frozen_string_literal: true
class EmailServices::Alias::Create < EmailServices::Base

  DOMAINS_LIST = %w[@inboxizer.com]
  WORDS_LIST = %w[flower sunset orange green white]

  attr_reader :number_of_aliases

  def initialize(number_of_aliases = 1)
    @number_of_aliases = number_of_aliases
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
      url = URI("https://box.inboxizer.com/admin/mail/aliases/add")

      https = Net::HTTP.new(url.host, url.port)
      https.use_ssl = true

      counter = 1
      padding = number_of_aliases.to_s.length
      while counter <= number_of_aliases
        email = random_email_address
        print "#{counter.to_s.rjust(padding, '0')}) Adding #{email}... "
        request = Net::HTTP::Post.new(url)
        request["Authorization"] = "Basic YWJkdWxsYWhAaW5ib3hpemVyLmNvbTpPbmVAMTUzNjY2"
        form_data = {'address' => email, 'forwards_to' => 'app-client@inboxizer.com'}.to_a
        request.set_form form_data, 'multipart/form-data'
        response = https.request(request)

        if response.code == '200'
          EmailAddress.find_or_create_by(email: email)
          @emails << email
          counter += 1
          puts "Added."
        else
          puts "======= Failed! #{response.read_body}"
        end
      end
    end

    def random_email_address
      word = WORDS_LIST.sample
      number = (rand * 10 ** 10).to_s[0..5].rjust(6, '0')
      domain = DOMAINS_LIST.sample

      [word, number, domain].join
    end
end
