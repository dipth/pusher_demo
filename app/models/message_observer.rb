class MessageObserver < ActiveRecord::Observer
  include ActionView::Helpers::TextHelper

  def after_create(message)
    Pusher['broadcast'].trigger!('total_messages_changed', {:value => pluralize(Message.count, 'message', 'messages')})
  end
end
