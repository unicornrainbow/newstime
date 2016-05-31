class HomeController < ActionController::Base

  def index
    if session[:screenname]
      redirect_to '/editions' and return
    end

    render layout: false
  end

  def sign_in
    user = User.find_by(screenname: params[:screenname])

    if user.valid_password?(params[:password])
      session[:screenname] = user.screenname
      redirect_to '/editions'
    else
      redirect_to '/' # Retry
    end

  rescue Mongoid::Errors::DocumentNotFound
      redirect_to '/' # Retry
  end

  def sign_out
    session.delete :screenname
    redirect_to '/'
  end


end
