class WelcomeController < ApplicationController

  def index
    @total_messages = Message.count
  end

end
