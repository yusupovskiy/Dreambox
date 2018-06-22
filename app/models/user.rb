class User < ApplicationRecord
  has_many :companies, dependent: :destroy
  # has_many :clients

  # Include default devise modules. Others available are:
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  validates :first_name, length: {minimum: 3}
  validates :last_name, length: {minimum: 3}

  # def confirmation_required?
  #   false
  # end

  module Role
    COMPANY_OWNER = 1
    CLIENT = 2
    STUFF = 4
  end
end
