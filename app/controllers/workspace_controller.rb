class WorkspaceController < ApplicationController
  respond_to :json
  skip_before_action :verify_authenticity_token

  def save_workspace
    workspace_params = params[:workspace]

    @workspace = current_user.workspace
    @workspace.color_palatte = workspace_params[:color_palatte]
    @workspace.save

    render text: "ok"
  end


end
