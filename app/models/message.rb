class Message < ActiveRecord::Base

  belongs_to :sender, :class_name => 'User'
  belongs_to :recipient, :class_name => 'User'

  validates :recipient, :presence => true
  validates :subject, :presence => true
  validates :body, :presence => true

end
