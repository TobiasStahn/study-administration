class User < ActiveRecord::Base
  authenticates_with_sorcery!
  
  # set different User roles
  ROLES = %w[admin student guest]

  # validates password and email
  validates :password, length: { minimum: 3 }, :on=>[:create]
  validates :password, confirmation: true, :on=>[:create]
  validates :password_confirmation, presence: true, :on=>[:create]
  
  validates :email, presence: true, email: true, uniqueness: true

  has_many :ratings

  has_many :events_users, :dependent => :destroy
  has_many :events, through: :events_users
  accepts_nested_attributes_for :events_users

  has_one :profile, dependent: :destroy
  belongs_to :course

  accepts_nested_attributes_for :profile

  def self.search(search)
    if search
      where("email LIKE ?", "%#{search}%")
    else
      where(nil)
    end
  end

end
