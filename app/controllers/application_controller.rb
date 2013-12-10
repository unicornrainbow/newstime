class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end

  def routing_error
    render "404", :status => 404
  end

  # CUSTOM EXCEPTION HANDLING
  #rescue_from Exception do |e|
    #throw :as
    ##error(e)
  #end

  #rescue_from ActiveRecord::RecordNotFound, :with => :rescue404
  #rescue_from ActionController::RoutingError, :with => :rescue404

  #def local_request?
    #false
  #end


  #def rescue404
    #throw :as
    #render :text => "as"
    ##your custom method for errors, you can render anything you want there
  #end

end
