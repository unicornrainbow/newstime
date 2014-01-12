class MastheadsController < ApplicationController

  def show
    @edition = Edition.find(params[:edition_id])
  end

end
