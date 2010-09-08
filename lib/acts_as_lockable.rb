# ActsAsLockable
require 'active_record'

module ActiveRecord
  module Acts
    module Lockable
      def self.included(base) # :nodoc:
        base.extend ClassMethods
      end

      module ClassMethods
        # == Configuration options
        #
        # * <tt>global</tt> - if set to true, any locked record will prevent getting lock on other records (table level locking)
        def acts_as_lockable(options = {})
          has_many :locks, :as => :locked
          cattr_accessor :global_lock
          self.global_lock = options[:global] || false

          include InstanceMethods
        end

        def lockable?
          self.included_modules.include?(InstanceMethods)
        end
      end

      module InstanceMethods #:nodoc:
        # Creates an entry in the locks table for this object for the given
        # username and transaction. Returns true if successful, false otherwise.
        # use secondary id if needed
        def lock(username, transaction, secondary_id = nil)
          expire_existing_locks
          return false if locked?(secondary_id)
          self.locks.create({:locked_by => username,
                             :locked_for => transaction,
                             :secondary_id => secondary_id,
                             :expires_at => Time.now + Lock::LEASE
                            }) ? true : false
        end

        # Deletes the entry in the locks table for this object for the given
        # username. Returns true if successful, false otherwise. Note: unlocking
        # an already unlocked object will return true.  Use secondary id if needed
        def unlock(username, secondary_id = nil, force = false)
          self.locks.destroy_all if force # Unlock the object regardless of who locked it
          expire_existing_locks
          return true if self.locks.empty?
          return false if username != locked_by(secondary_id)
          if (lo = self.locks.find_by_secondary_id(secondary_id).destroy rescue false)
            self.locks.delete(lo)
            true
          end
        end

        # Returns true if the object is currently locked, false otherwise.  Use secondary id if needed
        def locked?(secondary_id = nil)
          expire_existing_locks
          if self.locks.empty? and !self.global_lock
            false
          elsif self.global_lock
            return true if Lock.count(:conditions => "locked_type = '#{self.class}'") > 0 # Global lock on another record
          else
            return true if secondary_id.nil? # Parent lock denied since there is other locks
            return true if self.locks.find_by_secondary_id(nil) # Existing parent lock
            true if self.locks.find_by_secondary_id(secondary_id) # Child lock on the same child
          end
        end


        # Returns the username of the user who is currently locking this object
        # and nil if unlocked.  Use secondary id if needed
        def locked_by(secondary_id = nil)
          expire_existing_locks
          #yuck, well I had problems with the old way, so I spelt it out to debug
          #Its ugly, but it works and is not much slower...sorry code gods
          v = ''
          if !self.locks.empty?
            v = self.locks.find_by_secondary_id(secondary_id).locked_by rescue ''
          end
          v
        end

        # Returns the transaction/screen for which this object is currently locked
        # or nil if unlocked.
        def locked_for(secondary_id = nil)
          expire_existing_locks
          !self.locks.empty? && self.locks.find_by_secondary_id(secondary_id).locked_for rescue ''
        end

        # Returns the locked_records for which this object is currently locked
        # or false if unlocked.  Returns an array of hashes
        def locked_details
          expire_existing_locks
          !self.locks.empty? && self.locks.map {|lo| {:locked_by => lo.locked_by,
                                                      :locked_for => lo.locked_for,
                                                      :secondary_id => lo.secondary_id}}
        end

        # Display the locked details in human readable format
        def locked_message
          self.locked_details.inject('') {|msg, lock_detail| msg << "Locked by #{lock_detail[:locked_by]} for #{lock_detail[:locked_for]}#{(", with id: #{lock_detail[:secondary_id]}" if lock_detail[:secondary_id])}"}
        end

        private

        # Remove expired locks
        def expire_existing_locks
          Lock.transaction do
            self.locks.all(:lock => true).each do |lock|
              l = lock.destroy if lock.expired?
            end
            self.locks.reload
          end
        end
      end
    end
  end
end

ActiveRecord::Base.send(:include, ActiveRecord::Acts::Lockable)