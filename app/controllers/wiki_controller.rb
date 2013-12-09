require 'wiki_parser'

class WikiController < ApplicationController

  def index
    parser = WikiParser.new(data: File.read(WIKI_ROOT + "/index.wiki"))
    attributes = {
      title: "title",
      path: "path",
      html: parser.to_html
    }
    @wiki = OpenStruct.new(attributes)
  end

  def show
    # WARNING: Major security implementation if user can modify path
    path = params[:path]
    parser = WikiParser.new(data: File.read("#{WIKI_ROOT}/#{path}.wiki"))
    attributes = {
      title: path,
      path: path,
      html: parser.to_html
    }
    @wiki = OpenStruct.new(attributes)
  end

  def edit
    # WARNING: Major security implementation if user can modify path
    path = params[:path]
    parser = WikiParser.new(data: File.read("#{WIKI_ROOT}/#{path}.wiki"))
    attributes = {
      title: path,
      path: path,
      html: parser.to_html
    }
    @wiki = OpenStruct.new(attributes)
  end

end
