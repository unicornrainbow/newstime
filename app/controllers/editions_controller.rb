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
    edition_layout = LayoutModule.new('sfrecord/v1')
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

    # Hack to load paths for jquery and angular gems
    environment.append_path Gem.loaded_specs['angularjs-rails'].full_gem_path + "/vendor/assets/javascripts"
    environment.append_path Gem.loaded_specs['jquery-rails'].full_gem_path + "/vendor/assets/javascripts"

    # Is is a coffee file or a straight js? Need to have this done
    # automatically with sprockets or something.

    render text: environment["#{params[:path]}"], content_type: "text/javascript"
  end

  def stylesheet
    environment = Sprockets::Environment.new
    environment.append_path "#{Rails.root}/vendor/edition_layouts/sfrecord/v1/stylesheets"

    # Major hack to load bootstrap into this isolated environment courtesy of https://gist.github.com/datenimperator/3668587
    Bootstrap.load!
    environment.append_path Compass::Frameworks['bootstrap'].templates_directory + "/../vendor/assets/stylesheets"

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
