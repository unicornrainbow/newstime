class EditionsController < ApplicationController
  def index
    @editions = Edition.all
  end

  def new
    @edition = Edition.new
  end

  def create
    @edition = Edition.new(edition_params)
    if @edition.save
      redirect_to @edition
    else
      render "new"
    end
  end

  def show
    @edition = Edition.find(params[:id])
  end

  private

  def edition_params
    params.require(:edition).permit(:name)
  end

end
