class User
  include Mongoid::Document
  devise :database_authenticatable, :rememberable, :authentication_keys => [:screenname]

  field :screenname,         :type => String, :default => ""
  field :encrypted_password, :type => String, :default => ""

  field :reset_password_token,   :type => String
  field :reset_password_sent_at, :type => Time

  belongs_to :organization

  has_many :editions
  has_many :publications
  has_many :photos
  has_many :videos
  has_many :stories

  embeds_one :workspace

  def has_password?
    !encrypted_password.empty?
  end

end
