class PrintsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_edition, only: [:index, :create]

  def index
    @prints = @edition.prints
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

  def show
    @edition = Edition.find(params["edition_id"])
    @print = @edition.prints.where(version: params["version"]).first # Look up by version
    send_file "#{@print.share_path}/#{params[:path]}.#{params[:format]}", disposition: :inline
  end

  def view
    @print = Print.find(params["id"])
    send_file "#{@print.share_path}/#{params[:path]}.#{params[:format]}", disposition: :inline
  end

private

  def find_edition
    @edition = Edition.find(params[:edition_id])
  end

end
