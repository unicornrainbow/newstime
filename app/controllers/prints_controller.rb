class PrintsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_edition, only: [:index, :create]

  def index
    @prints = @edition.prints
  end

  def show
    render text: "Show Print"

  end

  def create
    @print = @edition.prints.create
    redirect_to :back, notice: "Print Started"
  end

private

  def find_edition
    @edition = Edition.find(params[:edition_id])
  end

end
