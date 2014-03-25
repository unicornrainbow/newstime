class ApiController <  ActionController::Base
  before_filter :authenticate_user!
  respond_to :json
end
