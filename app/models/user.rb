class User < ApplicationRecord
  has_many :memberships, dependent: :destroy
  has_many :shelters, through: :memberships
  
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
end
