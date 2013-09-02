Dashing Mailchimp Widget
=
Description
-

A [Dashing](http://shopify.github.com/dashing) widget to display your unread emails through [Gmail](http://www.gmail.com) using the Ruby [Gmail gem](https://github.com/dcparker/ruby-gmail).

Preview
-
![Screen Shot](http://i.imgur.com/D1SC3Ur.png)

Useage
-
To use this widget, copy `gmail.coffee`, `gmail.html`, and `gmail.scss` into the `/widgets/gmail` directory of your Dashing app.  This directory does not exist in new Dashing apps, so you may have to create it.  Copy the `gmail.rb` file into your `/jobs` folder, and include the Gmail gem in your `Gemfile`.  Edit the `gmail.rb` file to include your Gmail username and password.

To include the widget in a dashboard, add the following to your dashboard layout file:

#####dashboards/sample.erb

```HTML+ERB
...
  <li data-row="1" data-col="1" data-sizex="2" data-sizey="1">
    <div data-id="gmail" data-view="Gmail" data-title="Gmail"></div>
  </li>
...
```

Requirements
-
* [Gmail](http://www.gmail.com/) account
* The Ruby [Gmail gem](https://github.com/dcparker/ruby-gmail)

Code
-
#####widgets/gmail/gmail.coffee

```coffee

class Dashing.Gmail extends Dashing.Widget

  ready: ->

  onData: (data) ->
```

#####widgets/mailchimp/mailchimp.html

```HTML
<h1 class="title" data-bind="title"></h1>

<ul class="list-nostyle">
  <li>
    <p>
      <span class="label">From:</span>
      <span class="value" data-bind="gmail.from"></span>
    </p>
    <p>
      <span class="label">Subject:</span>
      <span class="value" data-bind="gmail.subject"></span>
    </p>
    <p>
      <span class="label">Message:</span>
    </p>
    <br>
    <p>
      <span class="value" data-bind="gmail.message"></span>
    </p>
    <br>
  </li>
</ul>

<p class="more-info">Powered by Gmail</p>
<p class="updated-at" data-bind="updatedAtMessage"></p>
```

#####widgets/mailchimp/mailchimp.scss

```SCSS
$background-color:  #793A57;
$value-color:       #fff;

$title-color:       rgba(255, 255, 255, 0.7);
$label-color:       rgba(255, 255, 255, 0.7);
$moreinfo-color:    rgba(255, 255, 255, 0.7);

.widget-gmail {
  background-color: $background-color;

  ol, ul {
    margin: 0 15px;
    text-align: left;
    color: $label-color;
  }

  ol {
    list-style-position: inside;
  }

  li {
    margin-bottom: 5px;
  }

  .list-nostyle {
    list-style: none;
  }

  .label {
    color: $label-color;
  }

  .value {
    float: right;
    margin-left: 12px;
    font-weight: 600;
    color: $value-color;
  }

  .updated-at {
    color: rgba(0, 0, 0, 0.3);
  }

  .more-info {
    color: $moreinfo-color;
  }

}
```

#####jobs/mailchimp.rb

```rb
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
```
