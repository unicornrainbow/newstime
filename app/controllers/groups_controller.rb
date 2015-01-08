class GroupsController < ApplicationController
  before_filter :authenticate_user!
  respond_to :html, :json

  def create
    @edition = Edition.find(params[:edition_id])
    @group = @edition.groups.create(group_params)
    render json: @group
  end

private

  def group_params
    params.fetch(:group, {}).permit(Group.attribute_names)
  end
end
