class SectionsController < ApplicationController

  before_filter :authenticate_user!

  def index
    @sections = Section.asc(:path)
  end

  def new
    if params[:edition_id]
      @edition = Edition.find(params[:edition_id])
      @section = @edition.sections.build
    else
      @section = Section.new
    end
  end

  def create
    @section = Section.new(section_params)

    # All section must have an organization
    @section.organization = current_user.organization

    if @section.save
      redirect_to @section, notice: "Section created successfully."
    else
      render "new"
    end
  end

  def edit
    @section = Section.find(params[:id])
  end

  def update
    @section = Section.find(params[:id])
    if @section.update_attributes(section_params)
      redirect_to @section, notice: "Section updated successfully."
    else
      render "edit"
    end
  end

  def show
    @section = Section.find(params[:id])
    @edition = @section.edition
    @pages = @section.pages
  end

  def destroy
    @section = Section.find(params[:id]).destroy
    redirect_to :back
  end

  def preview
    # Previews a copy of the section
    @section = Section.find(params[:id])
    render text: SectionRenderer.new(@section).render
  end

private

  def section_params
    params.require(:section).permit(:name, :edition_id, :layout_id, :path, :sequence)
  end

end
