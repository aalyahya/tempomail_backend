class EmailFetcherService
  require 'net/imap'

  HOST = Figaro.env.email_host
  USER_NAME = Figaro.env.email_user_name
  PASSWORD = Figaro.env.email_password
  INBOX = 'INBOX'
  LOGIN = 'LOGIN'

  def self.connection
    @@connection.examine(INBOX)
  rescue NameError, Errno::ECONNRESET, IOError
    @@connection = Net::IMAP.new(HOST, 993, usessl = true, certs = nil, verify = false)
    @@connection.authenticate(LOGIN, USER_NAME, PASSWORD)
    @@connection.examine(INBOX)
  ensure

    @@connection
  end
end
