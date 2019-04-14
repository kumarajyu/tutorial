class PicturesController < ApplicationController
  
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
  
end