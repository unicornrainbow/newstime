class EditionAssetsController < ApplicationController
  before_filter :authenticate_user!
  respond_to :html

  def javascripts
    @edition = Edition.find(params[:id])

    $sprocket_js_environments ||= {}
    environment = $sprocket_js_environments[@edition.layout_module_root]
    unless environment
      # Load environment into global cache.
      environment = Sprockets::Environment.new
      environment.append_path File.join(@edition.layout_module_root, "javascripts")

      # Hack to load paths for jquery and angular gems
      environment.append_path Gem.loaded_specs['angularjs-rails'].full_gem_path + "/vendor/assets/javascripts"
      environment.append_path Gem.loaded_specs['jquery-rails'].full_gem_path + "/vendor/assets/javascripts"

      $sprocket_js_environments[@edition.layout_module_root] = environment
    end

    result = environment["#{params[:path]}"]

    render text: result, content_type: "text/javascript"
  end

  def stylesheets
    @edition = Edition.find(params[:id])

    $sprocket_environments ||= {}
    environment = $sprocket_environments[@edition.layout_module_root]
    unless environment
      # Load environment into global cache.
      environment = Sprockets::Environment.new
      environment.append_path File.join(@edition.layout_module_root, "stylesheets")

      environment.context_class.class_eval do
        def asset_path(path, options = {})
          "/assets/#{path}"
        end
      end

      $sprocket_environments[@edition.layout_module_root] = environment
    end


    result = environment["#{params[:path]}.css"]
    render text: result, content_type: "text/css"
  end

  def fonts
    @edition = Edition.find(params[:id])
    fonts_root = File.join(@edition.layout_module_root, "fonts")


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

      images_root = File.join(@edition.layout_module_root, "images")

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
