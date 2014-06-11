class EditionAssetsController < ApplicationController
  before_filter :authenticate_user!
  respond_to :html

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

    # Find photo with the same name, from edition photos (Could be hashed)
    # TODO: Would be nice if this find was scoped better to the edition to avoid
    # name conflicts.
    photo = Photo.where(name: params[:path]).first
    if photo
      send_file photo.attachment.path, disposition: :inline
    else
      # No content image found, serve from layout

      images_root = "#{Rails.root}/layouts/#{@edition.layout_name}/images"

      # TODO: WARNING: Make sure the user can escape up about the font root (Chroot?)
      image_path = "#{images_root}/#{params["path"]}.#{params["format"]}"
      not_found unless File.exists?(image_path)

      #render text: File.read(image_path), content_type: 'image/svg+xml' # NOTE: This seems to be left over from serving svg data, may be useful later
      send_file image_path, disposition: :inline
    end
  end

  def videos
    @edition = Edition.find(params[:id])

    # Find video with the same name, from edition photos (Could be hashed)
    # TODO: Would be nice if this find was scoped better to the edition to avoid
    # name conflicts.
    video = Video.find_by(name: params[:path])
    send_file video.video_file.path, disposition: :inline
  end

end
