class EditionsController < ApplicationController
  def index
    @editions = Edition.all
  end

  def new
    @edition = Edition.new
  end

end
