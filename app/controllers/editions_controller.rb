class EditionsController < ApplicationController
  before_filter :authenticate_user!

  before_filter :find_edition, only: :compose

  respond_to :html

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
  end

  def compose
    # Redirect to main if no path specified
    redirect_to (compose_edition_path(@edition) + '/main.html') and return unless params['path']

    # Only respond to requests with an explict .html extension.
    not_found unless request.original_url.match(/\.html$/)

    # Set composing flag as indication to layout_module
    @composing = true

    # Reconstruct path with extension
    @path = "#{params['path']}.html"

    # Find section by path off of edtion.
    @section = @edition.sections.where(path: @path).first

    @layout_name = @edition.layout_name

    @template_name = @section.template_name.presence || @edition.default_section_template_name

    @layout_module = LayoutModule.new(@layout_name)
    render layout: 'layout_module'
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

  def javascripts
    # TODO: Action caching would probably word better.
    result = Rails.cache.fetch "editions/#{params["id"]}/javascript/#{params[:path]}" do
      @edition = Edition.find(params[:id])
      environment = Sprockets::Environment.new
      environment.append_path "#{Rails.root}/layouts/#{@edition.layout_name}/javascripts"


      # Hack to load paths for jquery and angular gems
      environment.append_path Gem.loaded_specs['angularjs-rails'].full_gem_path + "/vendor/assets/javascripts"
      environment.append_path Gem.loaded_specs['jquery-rails'].full_gem_path + "/vendor/assets/javascripts"

      # Is is a coffee file or a straight js? Need to have this done
      # automatically with sprockets or something.

      environment["#{params[:path]}"]
    end

    render text: result, content_type: "text/javascript"
  end

  def stylesheets
    result = Rails.cache.fetch "editions/#{params["id"]}/stylesheets/#{params[:path]}" do
      @edition = Edition.find(params[:id])
      environment = Sprockets::Environment.new
      environment.append_path "#{Rails.root}/layouts/#{@edition.layout_name}/stylesheets"

      # Major hack to load bootstrap into this isolated environment courtesy of https://gist.github.com/datenimperator/3668587
      Bootstrap.load!
      environment.append_path Compass::Frameworks['bootstrap'].templates_directory + "/../vendor/assets/stylesheets"

      environment.context_class.class_eval do
        def asset_path(path, options = {})
          "/assets/#{path}"
        end
      end

      result = environment["#{params[:path]}.css"]
    end
    render text: result, content_type: "text/css"
  end

  def fonts
    @edition = Edition.find(params[:id])
    fonts_root = "#{Rails.root}/layouts/#{@edition.layout_name}/fonts"

    # TODO: WARNING: Make sure the user can escape up about the font root (Chroot?)
    font_path = "#{fonts_root}/#{params["path"]}.#{params["format"]}"
    not_found unless File.exists?(font_path)
    send_file font_path
  end

  def images
    @edition = Edition.find(params[:id])
    images_root = "#{Rails.root}/layouts/#{@edition.layout_name}/images"

    # TODO: WARNING: Make sure the user can escape up about the font root (Chroot?)
    image_path = "#{images_root}/#{params["path"]}.#{params["format"]}"
    not_found unless File.exists?(image_path)
    #send_file image_path, type: 'image/svg+xml', disposition: 'inline'
    #didn't work...
    render text: File.read(image_path), content_type: 'image/svg+xml'

  end

private

  def find_edition
    @edition = Edition.find(params[:id])
  end

  def edition_params
    params.require(:edition).permit(:name, :source, :title, :masthead_id, :layout_id, :layout_name, :default_section_template_name, :publish_date, :store_link, :fmt_price)
  end

end
