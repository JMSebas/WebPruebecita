class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  has_many :tasks
  has_many :events

  
  validates :name, presence: true
  validates :lastname, presence: true
  validates :address, presence: true
  validates :phone, presence: true, format: { with: /\A\d{10}\z/, message: 'must be exactly 10 digits' }
  validates :birthdate, presence: true
  validates :username, presence: true
  validates :email, presence: true, uniqueness: true
  validates :password, presence: true, length: { minimum: 6 }

  def jwt_payload
    super
  end

end
