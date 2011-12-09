class MessagesController < ApplicationController

  def index
    @messages = current_user.received_messages
  end

  def sent
    @messages = current_user.sent_messages
  end

  def new
    @message = current_user.sent_messages.new
    find_users
  end

  def create
    @message = current_user.sent_messages.new(params[:message])
    if @message.save
      redirect_to messages_path, :notice => "Your message was sent!"
    else
      find_users
      render :action => 'new'
    end
  end

  protected

  def find_users
    @users = User.where("id <> ?", current_user.id)
  end

end
