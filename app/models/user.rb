class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher

  # Agrega :omniauthable aquí
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, :omniauthable, jwt_revocation_strategy: self,
         omniauth_providers: [:google_oauth2]

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
    super.merge({
      'email' => email,
      'name' => name,
      'lastname' => lastname,
      'username' => username
    })
  end
end
