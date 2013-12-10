require 'wiki_parser'

class BookmarksController < ApplicationController

  def index
    @bookmarks = [{}]
  end

  def new
    @bookmark = Bookmark.new
    #http://www.socialmediaexaminer.com/7-ways-to-use-psychological-influence-with-social-media-content/
  end

  def create
    debugger
    @bookmark = Bookmark.create(params[:bookmark])
    if @bookmark
      redirect_to bookmark_path(@bookmark)
    else
      render :new
    end
  end

end
