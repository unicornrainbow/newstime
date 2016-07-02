class HomeController < ActionController::Base

  def index
    if session[:screenname]
      redirect_to '/editions' and return
    end

    render layout: false
  end

  def sign_in
    if params[:screenname].empty?
      redirect_to '/editions' and return
    end

    user = User.find_by(screenname: params[:screenname].downcase)

    if user.has_password?
      if user.valid_password?(params[:password])
        session[:screenname] = user.screenname
        redirect_to '/editions'
      else
        redirect_to '/' # Retry
      end
    else
      session[:screenname] = user.screenname
      redirect_to '/editions'
    end

  rescue Mongoid::Errors::DocumentNotFound
      redirect_to '/' # Retry
  end

  def sign_out
    session.delete :screenname
    redirect_to '/'
  end


  def hot_muffins
  end


end
