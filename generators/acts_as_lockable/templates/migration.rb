class CreateLocks < ActiveRecord::Migration
  def self.up
    create_table :locks, :force => true do |t|
      t.integer  :locked_id
      t.string   :locked_type
      t.string   :locked_by,    :limit => 30    # Who is working on this object (if locked)
      t.string   :locked_for,   :limit => 20    # Why the object is locked
      t.datetime :expires_at                    # Lock expiry
      t.integer  :secondary_id                  # Lock child record without locking parent
    end

    add_index :locks, :locked_id
  end

  def self.down
    drop_table :locks
  end
end