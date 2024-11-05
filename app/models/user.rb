class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher

  # Agrega :omniauthable aquí
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, :omniauthable, jwt_revocation_strategy: self

  
         has_many :projects, dependent: :destroy

    enum role: {admin: 1, member: 2}

  def jwt_payload
    super.merge({
      'email' => email,
      'name' => name,
      'lastname' => lastname,
      'username' => username,
      'role' => role
    })
  end
end
