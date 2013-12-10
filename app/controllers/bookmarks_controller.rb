require 'wiki_parser'

class BookmarksController < ApplicationController

  def index
    @bookmarks = [{}]
  end

  def new
    @bookmark = Bookmark.new
  end

  def create
    debugger
    @bookmark = Bookmark.create(params[:bookmark].permit(:title, :url))
    if @bookmark
      redirect_to bookmark_path(@bookmark)
    else
      render :new
    end
  end

end
