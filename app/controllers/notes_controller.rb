class NotesController < ApplicationController

  def index
    # Get a listing of more recent notes.
    # Render index.
    #render text: ENV['NOTES_ROOT']
    @notes = Note.most_recent
  end

end
