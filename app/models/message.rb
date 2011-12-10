class Message < ActiveRecord::Base

  belongs_to :sender, :class_name => 'User'
  belongs_to :recipient, :class_name => 'User'

  validates :recipient, :presence => true
  validates :subject, :presence => true
  validates :body, :presence => true

  scope :by_user, lambda { |user| where(["sender_id = :user_id or recipient_id = :user_id", {:user_id => user.id}]) }

end
