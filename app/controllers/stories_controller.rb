class StoriesController < ApplicationController
  def index
    @editions = Story.all
  end
end
