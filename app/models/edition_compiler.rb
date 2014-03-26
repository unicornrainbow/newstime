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
      FileUtils.mkdir_p File.expand_path('..', output_dir.join(stylesheet_path))
      File.write(output_dir.join(stylesheet_path), "stylesheet contents")
    end


    javascript_assets.uniq!
    javascript_assets.each do |javascript_path|
      FileUtils.mkdir_p File.expand_path('..', output_dir.join(javascript_path))
      File.write(output_dir.join(javascript_path), "javascript content")
    end

    # TODO: Collect and render consumed media module assets
    # TODO: Collect and render content assets
    # TODO: Create content manifest
    # TODO: Zip and assocaiet with edition
  end

end
