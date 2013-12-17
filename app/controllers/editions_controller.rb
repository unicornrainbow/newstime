class EditionsController < ApplicationController
  def index
    @editions = Edition.all
  end
end
