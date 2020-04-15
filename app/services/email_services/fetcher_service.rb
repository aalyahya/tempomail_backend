# frozen_string_literal: true
class EmailServices::FetcherService
  require 'net/imap'

  REQUIRED_DATA = %w(ENVELOPE INTERNALDATE RFC822 RFC822.HEADER RFC822.TEXT)
  ENVELOPE_ADDRESSES = %w(from sender to cc bcc reply_to)
  INBOX_FOLDER = 'INBOX'
  JUNK_FOLDER = 'Spam'
  ARCHIVE_FOLDER = 'Archive'

  def self.call
    counter = 0

    new_messages.each do |message|
      counter += 1
      create_message! message
      archive_message! message.seqno
    end

    connection.expunge

    counter
  end

  private

    def self.new_messages
      messages = []
      connection.select(INBOX_FOLDER)
      messages.concat(connection.search(['ALL']))
      connection.select(JUNK_FOLDER)
      messages.concat(connection.search(['ALL']))
      connection.select(INBOX_FOLDER)
      messages.uniq.map { |message_id| connection.fetch(message_id, REQUIRED_DATA)&.first }
    end

    def self.create_message!(msg)
      envelope = msg.attr['ENVELOPE']
      return if Message.find_by(message_id: envelope.message_id)

      message = Message.new
      message.message_id = envelope.message_id
      message.seqno = msg.seqno

      message.date = envelope.date
      message.subject = envelope.subject
      message.in_reply_to = envelope.in_reply_to

      ENVELOPE_ADDRESSES.each do |type|
        method_name = "#{type}="
        message.send(method_name, [])

        next if envelope[type].blank?

        envelope[type].each do |address|
          element = {
              name: address.name,
              route: address.route,
              mailbox: address.mailbox,
              host: address.host
          }
          value = message.send("#{type}").push(element)
          message.send(method_name, value)
        end
      end

      message.rfc822 = msg.attr['RFC822']
      message.rfc822_header = msg.attr['RFC822.HEADER']
      message.rfc822_text = msg.attr['RFC822.TEXT']
      message.internal_date = msg.attr['INTERNALDATE']

      message.save!
    end

    def self.archive_message!(message_id)
      connection.store(message_id, "+FLAGS", [:Seen])
      connection.copy(message_id, ARCHIVE_FOLDER)
      connection.store(message_id, "+FLAGS", [:Deleted])
    end

    def self.connection
      connect_if_disconnected!
      @@connection
    end

    def self.connect_if_disconnected!
      begin
        @@connection.select(INBOX_FOLDER)
      rescue NameError, Errno::ECONNRESET, IOError
        @@connection = Net::IMAP.new(Figaro.env.email_host, 993, true)
        @@connection.login(Figaro.env.email_user_name, Figaro.env.email_password)
        @@connection.select(INBOX_FOLDER)
      end
    end
end

# msg = imap.fetch(message_id,'RFC822')[0].attr['RFC822']
# mail = Mail.read_from_string msg
#
# puts mail.subject
# puts mail.text_part.body.to_s
# puts mail.html_part.body.to_s
