class PhotosController < ApplicationController
  def index
    @editions = Photo.all
  end
end
