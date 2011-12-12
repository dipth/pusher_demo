# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
  window.broadcast_channel.bind 'total_messages_changed', (event) ->
    $('#total_messages').html(event.value)

  if window.private_channel
    window.private_channel.bind 'unread_messages_changed', (event) ->
      $('.unreadMessages').html(event.value).addClass('important')

    window.private_channel.bind 'new_message', (event) ->
      $.gritter.add
        title: "You've received a new message from " + event.sender
        text: '<blockquote>' + event.excerpt + '</blockquote><a href="' + event.url + '" class="btn success small">Read</a>'
        sticky: true
