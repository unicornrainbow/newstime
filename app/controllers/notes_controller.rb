class NotesController < ApplicationController

  def index
    render text: ENV['NOTES_ROOT']
  end

end
