require 'wiki_parser'

class AttachmentsController < ApplicationController

  before_filter :sanitize_path

  def sanitize_path
    if params[:path]
      # No relative linking
      #params[:path].gsub!(/\.\.\//, '/')
    end
  end

  def index
    date = Date.today - params[:days_ago].to_i.days
    root_path = "#{Attachment::ATTACHMENT_ROOT}/"

    today_path = "#{root_path}#{date.strftime("%Y/%m/%d")}"
    todays_entries = Dir["#{today_path}/*.*"]

    @attachments = todays_entries.map { |full_path|
      path, ext = full_path.match(/#{root_path}(.*)\.(.*)$/).try(:captures)
      basename = File.basename(path)
      created_at = parse_created_at("#{path}.#{ext}")

      attributes = {
        name: path,
        path: "/attachments/#{path}"
      }
      OpenStruct.new(attributes)
    }

    @attachments.reverse!

  end

  def show
    date = Date.today - params[:days_ago].to_i.days
    root_path = "#{Attachment::ATTACHMENT_ROOT}/"
    attachments = Dir["#{Attachment::ATTACHMENT_ROOT}/#{params[:path]}.*"]


    path, ext = attachments.first.match(/#{root_path}(.*)\.(.*)$/).try(:captures)

    basename = File.basename(path)
    created_at = parse_created_at("#{path}.#{ext}")

    # Need to be able to figure out thefile
    #send_file "#{Attachment::ATTACHMENT_ROOT}/#{params[:path]}.png"

    attributes = {
      name: path,
      path: "/attachments/#{path}"
    }
    @attachment = OpenStruct.new(attributes)
  end


private

  def parse_created_at(path)
    # Parse created at
    #2013/23/23/23:23:23.txt'
    date, name = path.match(/(\d{2,4}\/\d{1,2}\/\d{1,2})\//).try(:captures)
    Date.parse("#{date}") # Might need some conrrection for timezone.
  end

end
