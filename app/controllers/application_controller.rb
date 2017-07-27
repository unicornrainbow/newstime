class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end

  def routing_error
    render "404", status: 404
  end

  def logo
    render layout: false
  end

  def current_user
    if @current_user
      @current_user
    else
      @screenname = session[:screenname]
      if @screenname
        @current_user = User.find_by(screenname: @screenname )
      end
    end
  end

protected

  def force_trailing_slash
    redirect_to request.original_url + '/' unless request.original_url.match(/\/$/)
  end

  def after_sign_out_path_for(resource_or_scope)
    new_user_session_path
  end

  def find_edition

    if params[:id].length == 24
      @edition = Edition.find(params[:id])
    else
      query = current_user.try(:editions) || Edition
      @edition = query.find_by(slug: params[:id])
    end
  end

end
