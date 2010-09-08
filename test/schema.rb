ActiveRecord::Schema.define(:version => 1) do
  create_table :locks, :force => true do |t|
    t.integer  :locked_id
    t.string   :locked_type
    t.string   :locked_by,    :limit => 30
    t.string   :locked_for,   :limit => 20
    t.datetime :expires_at
    t.integer  :secondary_id
  end

  add_index :locks, :locked_id


  create_table "articles", :force => true do |t|
    t.integer  "site_id"
    t.string   "name"
    t.text     "content"
    t.string   "author_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "comments", :force => true do |t|
    t.integer  "article_id"
    t.string   "author_name"
    t.string   "site_url"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sites", :force => true do |t|
    t.string   "title"
    t.string   "site_url"
    t.datetime "created_at"
  end
end