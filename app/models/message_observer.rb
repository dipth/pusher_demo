class MessageObserver < ActiveRecord::Observer
  include ActionView::Helpers::TextHelper

  def after_create(message)
    Pusher['broadcast'].trigger!('total_messages_changed', {:value => pluralize(Message.count, 'message', 'messages')})
    Pusher["private-user_#{message.recipient.id}"].trigger('unread_messages_changed', {:value => message.recipient.received_messages.unread.count})
  end
end
