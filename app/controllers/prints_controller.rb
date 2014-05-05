class PrintsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_edition, only: [:index]

  def index
  end

private

  def find_edition
    @edition = Edition.find(params[:edition_id])
  end

end
