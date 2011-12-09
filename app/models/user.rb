class User < ActiveRecord::Base
  has_secure_password

  validates :username, :presence => true, :uniqueness => true
  validates :password, :presence => true, :on => :create

  has_many :sent_messages, :class_name => 'Message', :foreign_key => 'sender_id'
  has_many :received_messages, :class_name => 'Message', :foreign_key => 'recipient_id'

  def self.authenticate(username, password)
    find_by_username(username).try(:authenticate, password)
  end

  def to_s
    username
  end
end
