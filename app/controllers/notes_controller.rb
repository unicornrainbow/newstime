class NotesController < ApplicationController

  def index
    today = Date.today
    today_path = "#{NOTES_ROOT}/entries/#{today.strftime("%Y/%m/%d")}"
    todays_entries = Dir.entries(today_path)
    todays_entries.select! { |name| name =~ /.\.txt/ }
    @notes = todays_entries.map { |name|
      markdown = File.read(today_path + "/" + name)
      {
        name: name,
        markdown: markdown,
        html: $markdown.render(markdown)
      }
    }
    @notes.reverse!
  end

end
