class NotesController < ApplicationController

  # Parameters
  #
  #   days_ago - Interger value of number of days to go back.

  def index
    date = Date.today - params[:days_ago].to_i.days
    #date = Date.parse('2013/12/7')

    # Normalize date
    today_path = "#{NOTES_ROOT}/entries/#{date.strftime("%Y/%m/%d")}"
    todays_entries = Dir["#{today_path}/*.txt"]

    @notes = todays_entries.map { |path|
      root_path = "/Users/blake/.notes/entries/"
      web_path = path.match(/#{root_path}(.*)/).try(:captures).first

      markdown = File.read(path)
      {
        name: web_path,
        markdown: markdown,
        html: $markdown.render(markdown)
      }
    }
    @notes.reverse!
  end

  def show

    date = Date.today - params[:days_ago].to_i.days


  end

end
