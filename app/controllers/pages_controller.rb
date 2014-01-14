class PagesController < ApplicationController

  before_filter :authenticate_user!

  def index
    @pages = Page.asc(:path)
  end

  def new
    @page = Page.new

    # Assign section if passed.
    @page.section = Section.find(params[:section_id]) if params[:section_id]
  end

  def create
    @page = Page.new(page_params)

    # All section must have an organization
    @page.organization = current_user.organization

    if @page.save
      redirect_to @page, notice: "Page created successfully."
    else
      render "new"
    end
  end

  def edit
    @page = Page.find(params[:id])
  end

  def show
    @page = Page.find(params[:id])
  end

  def update
    @page = Page.find(params[:id])
    if @page.update_attributes(page_params)
      redirect_to @page, notice: "Page updated successfully."
    else
      render "edit"
    end
  end

private

  def page_params
    params.require(:page).permit(:name, :section_id, :source)
  end

end
