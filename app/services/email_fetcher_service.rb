class EmailFetcherService
  require 'net/imap'

  REQUIRED_DATA = %w(ENVELOPE INTERNALDATE RFC822 RFC822.HEADER RFC822.TEXT)
  ENVELOPE_ADDRESSES = %w(from sender to cc bcc in_reply_to reply_to)

  def self.call
    connect_if_disconnected!

    unread_messages = self.unread_messages

    unread_messages.each do |message|
      create_message! message
      mark_read! message.seqno
    end

    unread_messages.size
  end

  private

    def self.unread_messages
      list = []

      connection.search(["NOT", "SEEN"]).each do |uid|
        data = connection.fetch(uid, REQUIRED_DATA)&.first
        list << data if data
      end

      list
    end

    def self.create_message!(msg)
      return if Message.find_by(seqno: msg.seqno)

      message = Message.new
      message.seqno = msg.seqno
      message.internal_date = msg.attr['INTERNALDATE']
      message.rfc822 = msg.attr['RFC822']
      message.rfc822_header = msg.attr['RFC822.HEADER']
      message.rfc822_text = msg.attr['RFC822.TEXT']

      envelope = msg.attr['ENVELOPE']

      message.date = envelope.date
      message.subject = envelope.subject
      message.message_id = envelope.message_id

      ENVELOPE_ADDRESSES.each do |type|
        message.send("#{type}=", [])
        next if envelope[type].blank?

        envelope[type].each do |address|
          data = {name: address.name, route: address.route, mailbox: address.mailbox, host: address.host}
          message.send("#{type}=", message.send("#{type}").push(data))
        end
      end

      message.save!
    end

    def self.mark_read!(message_id)
      connection.store(message_id, "+FLAGS", [:Seen])
    end

    def self.connection
      connect_if_disconnected!
      @@connection
    end

    def self.connect_if_disconnected!
      begin
        @@connection.select('INBOX')
      rescue NameError, Errno::ECONNRESET, IOError
        @@connection = Net::IMAP.new(Figaro.env.email_host, 993, true)
        @@connection.login(Figaro.env.email_user_name, Figaro.env.email_password)
        @@connection.select('INBOX')
      end
    end
end
