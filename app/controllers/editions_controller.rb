class EditionsController < ApplicationController

  before_filter :authenticate_user!

  def index
    @editions = current_user.organization.editions.asc(:path)
  end

  def new
    @edition = Edition.new
  end

  def create
    @edition = Edition.new(edition_params)

    # All edtions must have an orgnaization
    @edition.organization = current_user.organization

    if @edition.save
      redirect_to @edition, notice: "Edition created successfully."
    else
      render "new"
    end
  end

  def edit
    @edition = Edition.find(params[:id])
    edition_layout = EditionLayout.new('sfrecord/v1')
    render text: edition_layout.render
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
    @sections = @edition.sections
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

  def javascript
    environment = Sprockets::Environment.new
    environment.append_path "#{Rails.root}/vendor/edition_layouts/sfrecord/v1/javascripts"
    render text: environment["#{params[:path]}.js"], content_type: "application/js"
  end

  def stylesheet
    environment = Sprockets::Environment.new
    environment.append_path "#{Rails.root}/vendor/edition_layouts/sfrecord/v1/stylesheets"
    environment.context_class.class_eval do
      def asset_path(path, options = {})
        "/assets/#{path}"
      end
    end
    render text: environment["#{params[:path]}.css"], content_type: "text/css"
  end

private

  def edition_params
    params.require(:edition).permit(:name, :source, :title, :masthead_id, :layout_id)
  end

end
