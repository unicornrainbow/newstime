class Workspace
  include Mongoid::Document

  field :color_palatte, type: Hash

  embedded_in :user

end
