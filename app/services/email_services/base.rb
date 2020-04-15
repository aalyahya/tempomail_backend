# frozen_string_literal: true
class EmailServices::Base

  require 'uri'
  require 'net/http'
  require 'net/imap'

  IMAP_HOST = Figaro.env.email_host
  IMAP_USER_NAME = Figaro.env.email_user_name
  IMAP_PASSWORD = Figaro.env.email_password
  INBOX_FOLDER = 'INBOX'
  JUNK_FOLDER = 'Spam'
  ARCHIVE_FOLDER = 'Archive'

  private

    def imap
      imap_connect_if_disconnected!
    end

    def imap_connect_if_disconnected!
      begin
        imap_select_inbox_folder!
      rescue NameError, Errno::ECONNRESET, IOError
        imap_connect!
        imap_select_inbox_folder!
      end
    end

    def imap_connect!
      @@connection = Net::IMAP.new(IMAP_HOST, 993, true)
      @@connection.login(IMAP_USER_NAME, IMAP_PASSWORD)
    end

    def imap_select_inbox_folder!
      @@connection.select(INBOX_FOLDER)
      @@connection
    end

    def imap_select_junk_folder!
      @@connection.select(JUNK_FOLDER)
      @@connection
    end

    def imap_select_archive_folder!
      @@connection.select(ARCHIVE_FOLDER)
      @@connection
    end

    def ffff
      # --user me@mydomain.com:yourpassword
      #curl -X POST -d "address=new_alias@mydomail.com" -d "forwards_to=my_email@mydomain.com"
      body = {

          AppSid: ENV['UNIFONIC_APP_SID'],
          SenderID: sender_id,
          Body: encoded_message,
          Recipient: phone_number[1..-1],
          CorrelationID: id,
          async: message_type != 'activation_code'
      }

      uri = URI.parse('https://box.inboxizer.com/admin/mail/aliases/add')
      uri.query = body.to_query

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = false

      header = {'Accept' => 'application/json'}
      header['Authorization'] = "Basic #{ENV['UNIFONIC_SMPP_USERNAME']}:#{ENV['UNIFONIC_SMPP_PASSWORD']}"

      request = Net::HTTP::Post.new(uri.request_uri, header)
      response = http.request(request)
      response_body = JSON.parse(response.body) rescue nil
      return true if response_body && response_body['success']

      # Duplicated SMS
      return true if response_body && !response_body['success'] && response_body['errorCode'] == 'ER-58'

      raise response.body
    end
end
