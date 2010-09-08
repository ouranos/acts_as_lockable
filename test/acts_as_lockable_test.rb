require 'test_helper'

class Site < ActiveRecord::Base
  acts_as_lockable :global => true
  has_many :articles
end

class Article < ActiveRecord::Base
  acts_as_lockable
  has_many :comments
  belongs_to :site
end

class Comment < ActiveRecord::Base
  belongs_to :article
end

class ActsAsLockableTest < ActiveSupport::TestCase
  fixtures :articles, :comments, :sites

  # ----------------------
  #       Row locking
  # ----------------------
  test "should grant a lock on an unlocked object" do
    assert articles(:piano).lock('John Smith', 'Test')
    assert articles(:piano).locked?
    assert_equal 'John Smith', articles(:piano).locked_by
  end

  test "should deny a lock on an locked object" do
    articles(:piano).lock('John Smith', 'Test')
    assert !articles(:piano).lock('John Doe', 'Test')
    assert articles(:piano).locked?
    assert_equal 'John Smith', articles(:piano).locked_by
  end

  # ----------------------
  #       Child lock
  # ----------------------
  # We'll lock comments through child lock on article
  test "should grant a child lock on an unlocked record" do
    assert articles(:music).lock('John Smith', 'Child Lock Test', comments(:first).id)
    assert articles(:music).locked?
    assert articles(:music).locked? comments(:first).id
  end

  test "should grand a child lock on an different child locked record" do
    articles(:music).lock('John Smith', 'Child Lock Test', comments(:first).id)
    assert articles(:music).lock('John Smith', 'Child Lock Test', comments(:learn_piano).id)
    assert articles(:music).locked?
    assert articles(:music).locked? comments(:first).id
    assert articles(:music).locked? comments(:learn_piano).id
  end

  test "should deny a child lock on a row locked record" do
    articles(:music).lock('John Smith', 'Child Lock Test')
    assert !articles(:music).lock('John Doe', 'Child Lock Test', comments(:first).id)
  end

  test "should deny a child lock on a same child locked record" do
    articles(:music).lock('John Smith', 'Child Lock Test', comments(:first).id)
    assert !articles(:music).lock('John Doe', 'Child Lock Test', comments(:first).id)
  end

  # ----------------------
  #       Global lock
  # ----------------------
  test "should grant a global lock if no record locked" do
    assert sites(:piano_site).lock('John Smith', 'Test Global Lock')
    assert sites(:piano_site).locked?
    assert_equal 'John Smith', sites(:piano_site).locked_by
  end

  test "should deny a global lock if record locked" do
    assert sites(:piano_site).lock('John Smith', 'Test Global Lock', true)
    assert sites(:tractor_site).locked?, "The record should be locked"
    assert !sites(:tractor_site).lock('John Doe', 'Test Global Lock', true), "Lock shouldn't be granted"
  end

  # ----------------------
  #       Unlocking
  # ----------------------
  test "should unlock object if locked by same user" do
    articles(:piano).lock('John Smith', 'Test')
    assert articles(:piano).unlock('John Smith')
    assert !articles(:piano).locked?
  end

  test "should not unlock object if locked by a different user" do
    articles(:piano).lock('John Smith', 'Test')
    assert !articles(:piano).unlock('John Doe')
    assert articles(:piano).locked?
  end
end
