class MessagesController < ApplicationController

  def index
    @messages = current_user.received_messages.order('created_at desc')
  end

  def sent
    @messages = current_user.sent_messages.order('created_at desc')
  end

  def new
    @message = current_user.sent_messages.new(:recipient_id => params[:recipient_id])
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

  def show
    @message = Message.by_user(current_user).find(params[:id])
  end

  def destroy
    @message = Message.by_user(current_user).find(params[:id])
    @message.destroy
    redirect_to messages_url, :notice => "The message was deleted!"
  end

  protected

  def find_users
    @users = User.where("id <> ?", current_user.id)
  end

end
