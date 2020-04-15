# frozen_string_literal: true
class EmailServices::Sync < EmailServices::Base

  REQUIRED_DATA = %w(ENVELOPE INTERNALDATE RFC822 RFC822.HEADER RFC822.TEXT)
  ENVELOPE_ADDRESSES = %w(from sender to cc bcc reply_to)

  def call
    counter = 0

    new_messages.each do |message|
      counter += 1
      create_message! message
      archive_message! message.seqno
    end

    imap.expunge

    counter
  end

  private

    def new_messages
      messages = []
      imap.select(INBOX_FOLDER)
      messages.concat(imap.search(['ALL']))
      imap.select(JUNK_FOLDER)
      messages.concat(imap.search(['ALL']))
      imap.select(INBOX_FOLDER)
      messages.uniq.map { |message_id| imap.fetch(message_id, REQUIRED_DATA)&.first }
    end

    def create_message!(msg)
      envelope = msg.attr['ENVELOPE']
      return if Message.where(message_id: envelope.message_id).exists?

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

    def archive_message!(message_id)
      imap.store(message_id, "+FLAGS", [:Seen])
      imap.copy(message_id, ARCHIVE_FOLDER)
      imap.store(message_id, "+FLAGS", [:Deleted])
    end
end

# msg = imap.fetch(message_id,'RFC822')[0].attr['RFC822']
# mail = Mail.read_from_string msg
#
# puts mail.subject
# puts mail.text_part.body.to_s
# puts mail.html_part.body.to_s
