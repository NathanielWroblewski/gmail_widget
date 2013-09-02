require 'gmail'

def from(email)
  sender = email.message.from.first
  sender ? sender : 'No info available'
end

def subject(email)
  text = email.message.text_part
  if text
    content = text.subject.try(:strip)
    content ? content[0..25] : 'No subject'
  else
    'No subject'
  end
end

def message(email)
  if email.message.text_part
    msg = email.message.text_part.body.raw_source.try(:strip)
    msg ? msg.to_s.gsub('*', '').gsub('=20', ' ')[0..170] + '...' : 'No content'
  else
    'No content'
  end
end

SCHEDULER.every '1m', first_in: 0 do |job|
  username = '' # <--- Enter your Gmail username here
  password = '' # <--- Enter your Gmail password here

  gmail = Gmail.new(username, password)
  unread = gmail.inbox.count(:unread)

  if unread > 0
    email = gmail.inbox.emails(:unread).first
    message = {
      from:    from(email),
      subject: subject(email),
      message: message(email)
    }
    send_event('gmail', gmail: message)
  else
    send_event('gmail', gmail: {subject: 'No new emails'})
  end
  gmail.logout
end
