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

    @notes = todays_entries.map { |full_path|
      root_path = "/Users/blake/.notes/entries/"
      path = full_path.match(/#{root_path}(.*)/).try(:captures).first

      markdown = File.read(full_path)
      {
        path: path,
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
