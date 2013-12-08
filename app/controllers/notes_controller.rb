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
      created_at = parse_created_at(path)

      markdown = File.read(full_path)
      {
        path: path,
        markdown: markdown,
        html: $markdown.render(markdown),
        created_at: created_at,
        formatted_date: created_at.strftime('%A, %B %e %Y'),
        formatted_time: created_at.strftime('%I:%M %p'),
        formatted_date_time: created_at.strftime('%A, %B %e, %Y, %l:%M %p')

      }
    }
    @notes.reverse!
  end

  def show
    date = Date.today - params[:days_ago].to_i.days

  end

private

  def parse_created_at(path)
    # Parse created at
    #2013/23/23/23:23:23.txt'
    date, time = path.match(/(\d{2,4}\/\d{1,2}\/\d{1,2})\/(\d{1,2}\:\d{1,2}\:\d{1,2})/).try(:captures)
    Time.parse("#{date} #{time}") # Might need some conrrection for timezone.
  end

end
