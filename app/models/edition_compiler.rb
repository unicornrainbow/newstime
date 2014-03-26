require 'fileutils'

# Compile and entire edition
class EditionCompiler

  attr_reader :edition, :html

  def initialize(edition)
    @edition = edition
  end

  def compile!
    output_dir = Rails.root.join('tmp', 'compiled_editions', @edition.id)
    FileUtils.mkdir_p output_dir
    sections = edition.sections
    stylesheet_assets = []
    javascript_assets = []
    sections.each do |section|
      sc = SectionCompiler.new(section)
      sc.compile!
      stylesheet_assets += sc.asset_recorder.stylesheet_assets
      javascript_assets += sc.asset_recorder.javascript_assets
      File.write(output_dir.join(section.path), sc.html)
    end

    stylesheet_assets.uniq!
    stylesheet_assets.each do |stylesheet_path|

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

      path = stylesheet_path.split('/').tap(&:shift).join('/') # Remove leading stylesheet/

      result = environment[path]

      FileUtils.mkdir_p File.expand_path('..', output_dir.join(stylesheet_path))
      File.write(output_dir.join(stylesheet_path), result)
    end

    javascript_assets.uniq!
    javascript_assets.each do |javascript_path|
      environment = Sprockets::Environment.new
      environment.append_path "#{Rails.root}/layouts/#{@edition.layout_name}/javascripts"

      # Hack to load paths for jquery and angular gems
      environment.append_path Gem.loaded_specs['angularjs-rails'].full_gem_path + "/vendor/assets/javascripts"
      environment.append_path Gem.loaded_specs['jquery-rails'].full_gem_path + "/vendor/assets/javascripts"

      # Is is a coffee file or a straight js? Need to have this done
      # automatically with sprockets or something.

      path = javascript_path.split('/').tap(&:shift).join('/') # Remove leading javascript/
      result = environment[path]

      FileUtils.mkdir_p File.expand_path('..', output_dir.join(javascript_path))
      File.write(output_dir.join(javascript_path), result)
    end

    # TODO: Collect and render consumed media module assets
    # TODO: Collect and render content assets
    # TODO: Create content manifest
    # TODO: Zip and assocaiet with edition
  end

end
