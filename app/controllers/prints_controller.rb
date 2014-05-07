class PrintsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_edition, only: [:index, :create]

  def index
    @prints = @edition.prints
  end

  def show
    # TODO: Return printed assets from disk or other backend
  end

  def create
    @print = @edition.prints.create
    @print.print_start
    redirect_to :back, notice: "Print Started"
  end

  def download
    @print = Print.find(params["id"])
    @edition = @print.edition
    send_file @print.zip_path
  end

private

  def find_edition
    @edition = Edition.find(params[:edition_id])
  end

end
