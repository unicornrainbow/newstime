class PhotosController < ApplicationController
  before_filter :authenticate_user!

  def index
    @photos = Photo.all
  end

  def new
    @photo = Photo.new
  end

  def create
    @photo = Photo.new(photo_params)
    if @photo.save
      redirect_to @photo, notice: "Photo created successfully."
    else
      render "new"
    end
  end

  def edit
    @photo = Photo.find(params[:id])
  end

  def update
    @photo = Photo.find(params[:id])
    if @photo.update_attributes(photo_params)
      redirect_to @photo, notice: "photo updated successfully."
    else
      render "edit"
    end
  end

  def show
    @photo = Photo.find(params[:id])
  end

  def delete
    @photo = Photo.find(params[:id]).destroy
    redirect_to :back
  end

private

  def photo_params
    params.require(:photo).permit(:name, :attachment)
  end

end
