class EditionsController < ApplicationController

  before_filter :authenticate_user!

  def index
    @editions = Edition.asc(:path)
  end

  def new
    @edition = Edition.new
  end

  def create
    @edition = Edition.new(edition_params)
    if @edition.save
      redirect_to @edition, notice: "Edition created successfully."
    else
      render "new"
    end
  end

  def edit
    @edition = Edition.find(params[:id])
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
    @edition = Edition.find(params[:id])
  end

  def destroy
    @edition = Edition.find(params[:id]).destroy
    redirect_to :back
  end

  def preview
    # Previews a copy of the edition
    @edition = Edition.find(params[:id])
    renderer = EditionRenderer.new(@edition)
    @edition.html = renderer.render
    @edition.save
    render text: @edition.html
  end

private

  def edition_params
    params.require(:edition).permit(:name, :source, :html)
  end

end
