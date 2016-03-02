class PhotosController < ApplicationController
  before_filter :authenticate_user!
  respond_to :json, :html

  def index
    @photos = Photo.all
  end

  def new
    @photo = Photo.new
  end

  def create
    @photo = Photo.new(photo_params)
    @photo.save
    render :show
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

  def destroy
    @photo = Photo.find(params[:id]).destroy
    redirect_to :back
  end

private

  def photo_params
    params.require(:photo).permit(:name, :attachment)
  end

end
