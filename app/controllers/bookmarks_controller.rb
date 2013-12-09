require 'wiki_parser'

class BookmarksController < ApplicationController

  def index
    @bookmarks = [{}]
  end

end
