class PicturesController < ApplicationController
  
  def new
  end
  
  def create
    path = 'public/images/'
    picture = Picture.create
    File.open("#{Rails.root}/#{path}/#{picture.id}.png", "wb") { |f|
      f.write Base64.decode64(params[:data].sub!('data:image/png;base64,', ''))
    }
    if Picture.count > 100
      picture = Picture.order(:id).first
      begin
        File.unlink("#{Rails.root}/#{path}/#{picture.id}.png", "wb")
      rescue => exc
        p exc
      end
      picture.destroy
    end

    render :nothing => true
  end
  
  def index
    ids = []
    Picture.all.reverse.each do |picture|
      ids << picture.id
    end
    @response = ids.join(',')
  end

  def list
    ids = []
    Picture.all.reverse.each do |picture|
      ids << picture.id
    end
    # render :text => ids.join(',')

    @response = ids.join(',')
    respond_to do |format|
      format.html # .html.erb
      format.xml   { render xml: ids }
      format.json  { render json: ids }
      format.text  { render text: ids.join(',') }
    end
  end

  # DELETE /picture/1
  # DELETE /picture/1.json
  def destroy
    @pict = Picture.find(params[:id])
    @pict.destroy if @pict

    respond_to do |format|
      format.html { redirect_to pictures_url }
      format.json { head :no_content }
    end
  end
end