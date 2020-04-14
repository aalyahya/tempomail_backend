# frozen_string_literal: true
class EmailFetcherService
  require 'net/imap'

  REQUIRED_DATA = %w(ENVELOPE INTERNALDATE RFC822 RFC822.HEADER RFC822.SIZE RFC822.TEXT)

  def self.unread
    list = []

    connection.search(["RECENT"]).each do |uid|
      data = connection.fetch(uid, REQUIRED_DATA)&.first
      list << data if data
    end

    list
  end

  private

    def self.connection
      connect_if_disconnected!
      @@connection
    end

    def self.connect_if_disconnected!
      begin
        @@connection.examine('INBOX')
      rescue NameError, Errno::ECONNRESET, IOError
        @@connection = Net::IMAP.new(Figaro.env.email_host, 993, usessl = true, certs = nil, verify = false)
        @@connection.authenticate('LOGIN', Figaro.env.email_user_name, Figaro.env.email_password)
        @@connection.examine('INBOX')
      end
    end
end
