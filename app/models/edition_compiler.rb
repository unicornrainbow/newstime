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
    sections.each do |section|
      sc = SectionCompiler.new(section)
      sc.compile!
      File.write(output_dir.join(section.path), sc.html)
    end

    # TODO: Collect and render consumed media module assets
    # TODO: Collect and render content assets
    # TODO: Create content manifest
    # TODO: Zip and assocaiet with edition
  end

end
