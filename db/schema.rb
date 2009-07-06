# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20081211144147) do

  create_table "alternates", :force => true do |t|
    t.string   "word"
    t.string   "language"
    t.integer  "phrase_id"
    t.integer  "rank"
    t.datetime "marked_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  create_table "children", :force => true do |t|
    t.string   "word"
    t.string   "language"
    t.string   "variety"
    t.integer  "definition_id"
    t.integer  "rank"
    t.datetime "marked_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.string   "second_word"
    t.string   "third_word"
  end

  add_index "children", ["definition_id"], :name => "index_children_on_definition_id"
  add_index "children", ["id"], :name => "index_children_on_id"

  create_table "comments", :force => true do |t|
    t.text     "comment_field"
    t.string   "name"
    t.integer  "phrase_id"
    t.integer  "rank"
    t.datetime "marked_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["id"], :name => "index_comments_on_id"
  add_index "comments", ["phrase_id"], :name => "index_comments_on_phrase_id"

  create_table "definitions", :force => true do |t|
    t.text     "meaning"
    t.string   "example"
    t.string   "part_of_speech"
    t.integer  "phrase_id"
    t.integer  "rank"
    t.datetime "marked_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  add_index "definitions", ["id"], :name => "index_definitions_on_id"
  add_index "definitions", ["phrase_id"], :name => "index_definitions_on_phrase_id"
  add_index "definitions", ["rank"], :name => "index_definitions_on_rank"
  add_index "definitions", ["user_id"], :name => "index_definitions_on_user_id"

  create_table "logged_exceptions", :force => true do |t|
    t.string   "exception_class"
    t.string   "controller_name"
    t.string   "action_name"
    t.text     "message"
    t.text     "backtrace"
    t.text     "environment"
    t.text     "request"
    t.datetime "created_at"
  end

  create_table "mugshots", :force => true do |t|
    t.integer  "parent_id"
    t.string   "content_type"
    t.string   "filename"
    t.string   "thumbnail"
    t.integer  "size"
    t.integer  "width"
    t.integer  "height"
    t.integer  "rank"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "phrase_id"
    t.integer  "user_id"
    t.datetime "marked_at"
  end

  add_index "mugshots", ["id"], :name => "index_mugshots_on_id"
  add_index "mugshots", ["phrase_id"], :name => "index_mugshots_on_phrase_id"

  create_table "open_id_authentication_associations", :force => true do |t|
    t.integer "issued"
    t.integer "lifetime"
    t.string  "handle"
    t.string  "assoc_type"
    t.binary  "server_url"
    t.binary  "secret"
  end

  create_table "open_id_authentication_nonces", :force => true do |t|
    t.integer "timestamp",  :null => false
    t.string  "server_url"
    t.string  "salt",       :null => false
  end

  create_table "phrases", :force => true do |t|
    t.string   "word"
    t.string   "language"
    t.integer  "rank"
    t.datetime "marked_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.string   "second_word"
    t.string   "third_word"
    t.string   "pronunciation"
  end

  add_index "phrases", ["created_at"], :name => "index_phrases_on_created_at"
  add_index "phrases", ["user_id"], :name => "index_phrases_on_user_id"
  add_index "phrases", ["word", "language"], :name => "index_phrases_on_word_and_language"

  create_table "relateds", :force => true do |t|
    t.string   "word"
    t.string   "language"
    t.integer  "phrase_id"
    t.integer  "rank"
    t.datetime "marked_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  create_table "sessions", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "simple_captcha_data", :force => true do |t|
    t.string   "key",        :limit => 40
    t.string   "value",      :limit => 6
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "email"
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.string   "activation_code",           :limit => 40
    t.datetime "activated_at"
    t.string   "state",                                   :default => "passive"
    t.datetime "deleted_at"
    t.string   "identity_url"
    t.integer  "rank"
    t.integer  "extra_rank"
  end

  add_index "users", ["id"], :name => "index_users_on_id"

end
