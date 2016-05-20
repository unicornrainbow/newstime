class HomeController < ActionController::Base

  def index
		if cookies[:screenname]
			redirect_to '/editions' and return
		end

		render layout: false
	end

	def sign_in
		screenname = params['screenname']
		password   = params['password']

		users = [['rashiki', 'love'], ['mom', 'mom']]

		if users.include?([screenname, password])

			cookies[:screenname] = screenname
			redirect_to '/editions'
		else
			redirect_to '/' # Retry
		end

	end

	def sign_out
		cookies.delete :screenname
		redirect_to '/'
	end


end
