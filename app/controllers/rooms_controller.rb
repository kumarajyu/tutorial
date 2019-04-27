class RoomsController < ApplicationController
  
  
  def show
    @messages = Message.all.order(created_at: :desc) #=>新しい順の投稿一覧
  end
  
  def destroy
    @messages = Message.find_by(id: params[:id])
    @messages.destroy
    flash[:success] = "投稿を削除しました！"
    redirect_to chat_path
  end
end
