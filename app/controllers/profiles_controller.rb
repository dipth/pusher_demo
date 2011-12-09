class ProfilesController < ApplicationController

  before_filter :find_user

  def edit
  end

  def update
    if @user.update_attributes(params[:user])
      redirect_to :root, :notice => "Your profile was updated!"
    else
      render :action => 'edit'
    end
  end

  protected

  def find_user
    @user = current_user
  end

end
