class VideosController < ApplicationController
  before_filter :authenticate_user!

  def index
    @videos = Video.all
  end

  def new
    @video = Video.new
  end

  def create
    @video = Video.new(video_params)
    if @video.save
      redirect_to @video, notice: "Video created successfully."
    else
      render "new"
    end
  end

  def edit
    @video = Video.find(params[:id])
  end

  def update
    @video = Video.find(params[:id])
    if @video.update_attributes(video_params)
      redirect_to @video, notice: "video updated successfully."
    else
      render "edit"
    end
  end

  def show
    @video = Video.find(params[:id])
  end

  def destroy
    @video = Video.find(params[:id]).destroy
    redirect_to :back
  end

private

  def video_params
    params.require(:video).permit(:name, :video_file, :cover_image)
  end

end
