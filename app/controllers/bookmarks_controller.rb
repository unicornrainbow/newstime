require 'wiki_parser'

class BookmarksController < ApplicationController

  def index
    @bookmarks = [{}]
  end

  def new
    @bookmark = Bookmark.new
  end

  def create
    @bookmark = Bookmark.create(params[:bookmark].permit(:title, :url, :description))
    if @bookmark
      redirect_to bookmark_path(@bookmark)
    else
      render :new
    end
  end

end
