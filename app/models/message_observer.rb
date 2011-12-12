class MessageObserver < ActiveRecord::Observer
  include ActionView::Helpers::TextHelper

  def after_create(message)
  end
end
