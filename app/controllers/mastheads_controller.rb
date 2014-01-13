class MastheadsController < ApplicationController

  def index
    @mastheads = Masthead.asc(:path)
  end

  def new
    @masthead = Masthead.new
  end

  def create
    @masthead = Masthead.new(masthead_params)
    if @masthead.save
      redirect_to @masthead, notice: "Masthead created successfully."
    else
      render "new"
    end
  end

  def edit
    #if params
    #@edition = Edition.find(params[:id])
    #@masthead = @edition.masthead
  end

  def update
    @edition = Edition.find(params[:id])
    if @edition.update_attributes(edition_params)
      redirect_to @edition, notice: "Edition updated successfully."
    else
      render "edit"
    end
  end

  def show
    @masthead = Masthead.find(params[:id])
    #@edition = Edition.find(params[:edition_id])
    #masthead = @edition.masthead
  end

private

  def masthead_params
    params.require(:masthead).permit(:name, :source, :title)
  end

end
