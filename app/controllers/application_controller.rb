class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :current_user, :unread_messages_count

  protected

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def unread_messages_count
    @unread_messages_count ||= current_user ? current_user.received_messages.unread.count : 0
  end
end
