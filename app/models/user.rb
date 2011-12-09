class User < ActiveRecord::Base
  has_secure_password

  validates :username, :presence => true, :uniqueness => true
  validates :password, :presence => true, :on => :create

  def self.authenticate(username, password)
    find_by_username(username).try(:authenticate, password)
  end
end
