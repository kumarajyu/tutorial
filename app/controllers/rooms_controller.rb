class RoomsController < ApplicationController
  
  
  def show
    @messages = Message.all
  end
  
  def destroy
    @messages.destroy
    flash[:success] = "投稿を削除しました！"
    redirect_to request.referrer || root_url
  end
end
