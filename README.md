# Pusher Demo

This is a small demo application, that will show how quickly and easily you can integrate Pusher into your web application.

The application is a simple messaging app, where users can register and send messages to other users.
We will add Pusher integration in 3 levels:

* Add realtime update of the hero-unit on the front page, showing how many messages the users have sent to date.
* Add realtime update of the label showing a logged in user how many unread messages he has.
* Add a realtime notification for users when they receive a new message.

The project is separated into two different branches:

* [master](https://github.com/dipth/pusher_demo/commits/master): This is the application before Pusher has been integrated. It will be our starting point.
* [finished_pusher_integration](https://github.com/dipth/pusher_demo/commits/finished_pusher_integration): This branch contains the finished application with Pusher integration. If you compare this branch to master, you can see each step towards pusher integration as a commit.

In the following sections, I will desribe how I integrated Pusher in this app.

## First things first

The first thing you'll want to do, is to log onto http://pusher.com and sign up for a free account.
From there you also need to setup a new application in the Pusher dashboard and get the API-keys for the app.

You should store thise keys in the environment. I'm using pow as a development server, so I've created a .powrc file in the root of the project with the following content:

    export PUSHER_APP_ID="INSERT YOUR APP ID HERE"
    export PUSHER_KEY="INSERT YOUR KEY HERE"
    export PUSHER_SECRET="INSERT YOUR SECRET HERE"

## 1. Install Pusher

To install Pusher, simply add the pusher gem to your ```Gemfile``` and do a ```bundle install```

    gem 'pusher'

Next we'll want to create an initializer to let Pusher know about the API-keys.

In ```config/initializers/pusher.rb```

    Pusher.app_id = ENV['PUSHER_APP_ID']
    Pusher.key    = ENV['PUSHER_KEY']
    Pusher.secret = ENV['PUSHER_SECRET']

Finally we need to include the Pusher Javascript client.

In ```app/views/layouts/application.html.erb```

    <head>
      ...
      <%= javascript_include_tag "http://js.pusherapp.com/1.9/pusher.min.js", "application" %>
      ...
    </head>

[See the commit for this step](https://github.com/dipth/pusher_demo/commit/d1bbf504a6db0c6e11016535996aa34b6a40ab19)

## 2. Make Pusher App Key available to client side

Since the client side also needs to talk to Pusher, we also need to make the Application Key available to the client side.

In ```app/views/layouts/application.html.erb```

    <head>
      <script type="text/javascript">
        window.pusher_key = '<%= ENV['PUSHER_KEY'] %>';
      </script>

[See the commit for this step](https://github.com/dipth/pusher_demo/commit/fbe00062750e9702e32e17f0a079304268b5e80a)

## 3. Initialize Pusher on client side and connect to public channel

Next up we'll initialize Pusher in our javascript and connect to a public channel.

Pusher has 3 kinds of channels:

* Public: These channels are, as you might think, public which means that anyone can listen in on what happens there.
* Private: These channels are private and only authorizes users can connect to these channelse.
* Pressence: These special channels are used to track who's online. This type of channel will not be covered here, but check out Pushers official documentation for more info.

In ```app/assets/javascripts/application.js```

    window.pusher = new Pusher(window.pusher_key);
    window.broadcast_channel = pusher.subscribe('broadcast');

Note that I store the ```pusher``` and ```broadcast_channel``` in ```window``` - which is to make it available to our coffeescript in the later steps.

[See the commit for this step](https://github.com/dipth/pusher_demo/commit/c8734c84c237cd30f23f60a2c53269705c0b3e53)

## 4. Push "Total Messages Sent"

The first thing that we'll add realtime functionality to, is the hero-unit on the front page, that shows how many messages our users have sent to date.

For this purpose I've prepared an Observer to observe when new Message-models have been created. We will use this observer to push an event to our connected clients, when a message is created.

In ```app/models/message_observer.rb```

    def after_create(message)
      Pusher['broadcast'].trigger!('total_messages_changed', {:value => pluralize(Message.count, 'message', 'messages')})
    end

Notice the syntax of the Pusher gem:

    Pusher[CHANNEL_NAME].trigger!(NAME_OF_EVENT, HASH_OF_DATA)

We defined our channel-name in the previous step to **broadcast** and here we define the name of the event to **total_messages_changed**

*Note that just sending a count of total messages is a naive approach, since it can result in race conditions. But it will suffice for demonstration purposes.*

Next we'll want to listen for this event on the client side.

In ```app/assets/javascripts/messages.js.coffee```

    $ ->
      window.broadcast_channel.bind 'total_messages_changed', (event) ->
        $('#total_messages').html(event.value)

Also notice the syntax of the Pusher Javascript SDK:

    CHANNEL.bind(NAME_OF_EVENT, EVENT_HANDLER)

Every key that you set in the data-hash on the server will be available as a property in the event-object that is passed to the event-handler.

The hero-unit on the front page now updates automatically every time a new message is sent.

[See the commit for this step](https://github.com/dipth/pusher_demo/commit/cdee3890990971d1642183147fddfdddf1059b2b)

## 5. Uncomment PusherController#auth

We now want to push the number of unread messages to a user, when he receives new messages, but to do this we're going to need to use private channels, because we don't want our users to know each others number of unread messages.

The way Pusher has implemented private channels is that when a client tries to connect to a private channel, the Pusher Javascript SDK will perform a POST request to your app with information about the channel that he is trying to connect to, and unique socket id.
It is then up to us to determine if the user is authorized to connect to this channel.

If the user is authorized, we need to call the Pusher API with the unique socket id. This will return a key that we should pass on to the client. The client will then use this key to finish connecting to the channel.

By default Pusher will make the POST request to ```/pusher/auth```

I've already prepared a controller to handle this, so simply uncomment the content of the auth-action in PusherController:

    if current_user && params[:channel_name] == "private-user_#{current_user.id}"
      render :json => Pusher[params[:channel_name]].authenticate(params[:socket_id])
    else
      render :text => "Not authorized", :status => '403'
    end

[See the commit for this step](https://github.com/dipth/pusher_demo/commit/3552a69d075ded16bc7b0d12b34f4c3e8a1dbb83)

## 6. Make the id of the current user available to the client side

Every channel that has a name that starts with ```private-``` will be a private channel.

We're going to name our private channels: ```private-user_ID_OF_USER```.

Example: ```private-user_42```

So for the client side to be able to know what channel to connect to, we need to expose the id of the current user.

In ```app/views/layouts/application.html.erb```

    <head>
      <script type="text/javascript">
        ...
        <%= "window.user_id = #{current_user.id};" if current_user %>
      </script>

[See the commit for this step](https://github.com/dipth/pusher_demo/commit/b624df0042ef52b45ca7e6f2c1e5936f77cf4b45)

## 7. Subscribe to private channel

We can now connect to the private channel, if a user is logged in.

In ```app/assets/javascripts/application.js```

    ...
    if (window.user_id)
      window.private_channel = pusher.subscribe('private-user_' + window.user_id);

[See the commit for this step](https://github.com/dipth/pusher_demo/commit/43f3bb699a18ea66607071e71b03b5d289e2a74f)

## 8. Push "Unread Messages Count"

Now we can use this private channel to send the number of unread messages to a user, when he receives a new message.

In ```app/models/message_observer.rb```

    def after_create(message)
      ...
      Pusher["private-user_#{message.recipient.id}"].trigger('unread_messages_changed', {:value => message.recipient.received_messages.unread.count})
    end

And we can listen for this event on the client side.

In ```app/assets/javascripts/messages.js.coffee```

    if window.private_channel
      window.private_channel.bind 'unread_messages_changed', (event) ->
        $('.unreadMessages').html(event.value).addClass('important')

[See the commit for this step](https://github.com/dipth/pusher_demo/commit/558fbc313db6554178316f7ac76340c0bc92e55c)

## 9. Push "New Message Notification"

Finally we are going to push a notification to users, when they receive a new message, with an excerpt of the message and a link to read the message.

For this we're going to use the Gritter jQuery Plugin, which have already been prepared in the application.

In ```app/models/message_observer.rb```

    def after_create(message)
      ...
      Pusher["private-user_#{message.recipient.id}"].trigger('new_message', {
        :sender => message.sender.username,
        :subject => message.subject,
        :excerpt => truncate(message.body, :length => 150),
        :url => "/messages/#{message.id}"
      })
    end

In ```app/assets/javascripts/messages.js.coffee```

    if window.private_channel
      ...
      window.private_channel.bind 'new_message', (event) ->
        $.gritter.add
          title: "You've received a new message from " + event.sender
          text: '<blockquote>' + event.excerpt + '</blockquote><a href="' + event.url + '" class="btn success small">Read</a>'
          sticky: true

[See the commit for this step](https://github.com/dipth/pusher_demo/commit/92e844d8444ed903668b4cf2194af9d683cedd3a)

## Done

This concludes the demo and I hope you now have a clear picture of how easy it is to integrate Pusher into a Rails application.

Please feel free to message me if you have any questions.

Oh, and you can use the source-code for this demo application in any way you like, but attribution is always greatly appreciated! :)
