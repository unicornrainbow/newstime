require 'wiki_parser'

class BookmarksController < ApplicationController

  def index
    @bookmarks = [{}]
  end

  def new
    @bookmark = OpenStruct.new
  end

end
