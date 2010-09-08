class Lock < ActiveRecord::Base
  belongs_to :locked, :polymorphic => true

  LEASE = (8 * 60 * 60) # Length of lock in seconds  8 hours

  validates_presence_of :locked_by, :locked_for, :expires_at

  def expired?
    expires_at < Time.now
  end
end