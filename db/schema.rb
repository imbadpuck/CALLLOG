# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20171209041936) do

  create_table "attachment_files", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "comments", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.text "content"
    t.integer "type"
    t.string "note"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "default_values", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "label"
    t.string "name"
    t.json "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "function_systems", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name"
    t.string "label"
    t.string "description"
    t.integer "status", default: 0
    t.integer "parent_id"
    t.integer "lft", null: false
    t.integer "rgt", null: false
    t.integer "depth", default: 0, null: false
    t.integer "children_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["lft"], name: "index_function_systems_on_lft"
    t.index ["parent_id"], name: "index_function_systems_on_parent_id"
    t.index ["rgt"], name: "index_function_systems_on_rgt"
  end

  create_table "group_users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "regency"
    t.float "role_level", limit: 24
    t.bigint "user_id", null: false
    t.bigint "group_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_group_users_on_group_id"
    t.index ["user_id"], name: "index_group_users_on_user_id"
  end

  create_table "groups", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "label"
    t.string "name"
    t.string "content"
    t.integer "purpose", default: 2
    t.integer "parent_id"
    t.integer "lft", null: false
    t.integer "rgt", null: false
    t.integer "depth", default: 0, null: false
    t.integer "children_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["label"], name: "index_groups_on_label"
    t.index ["lft"], name: "index_groups_on_lft"
    t.index ["parent_id"], name: "index_groups_on_parent_id"
    t.index ["rgt"], name: "index_groups_on_rgt"
  end

  create_table "notifications", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "title"
    t.text "content"
    t.integer "notify_type"
    t.datetime "send_time"
    t.bigint "receiver_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["receiver_id"], name: "index_notifications_on_receiver_id"
  end

  create_table "sub_comments", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.text "content"
    t.bigint "comment_id", null: false
    t.bigint "user_id"
    t.integer "type"
    t.string "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["comment_id"], name: "index_sub_comments_on_comment_id"
    t.index ["user_id"], name: "index_sub_comments_on_user_id"
  end

  create_table "ticket_assignments", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "user_type", default: 0
    t.bigint "user_id"
    t.bigint "group_id"
    t.bigint "ticket_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_ticket_assignments_on_group_id"
    t.index ["ticket_id"], name: "index_ticket_assignments_on_ticket_id"
    t.index ["user_id"], name: "index_ticket_assignments_on_user_id"
  end

  create_table "tickets", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "title"
    t.text "content"
    t.integer "status"
    t.integer "priority"
    t.datetime "deadline"
    t.datetime "resolved_at"
    t.datetime "closed_at"
    t.integer "parent_id"
    t.integer "lft", null: false
    t.integer "rgt", null: false
    t.integer "depth", default: 0, null: false
    t.integer "children_count", default: 0, null: false
    t.bigint "creator_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_tickets_on_creator_id"
    t.index ["lft"], name: "index_tickets_on_lft"
    t.index ["parent_id"], name: "index_tickets_on_parent_id"
    t.index ["rgt"], name: "index_tickets_on_rgt"
  end

  create_table "user_functions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "user_id"
    t.bigint "group_id"
    t.bigint "function_system_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["function_system_id"], name: "index_user_functions_on_function_system_id"
    t.index ["group_id"], name: "index_user_functions_on_group_id"
    t.index ["user_id"], name: "index_user_functions_on_user_id"
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "username"
    t.string "avatar"
    t.string "name"
    t.string "code"
    t.integer "status", default: 0
    t.string "type"
    t.date "birthdate"
    t.integer "gender"
    t.string "phone"
    t.string "email"
    t.string "password"
    t.string "encrypted_password", default: ""
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "comments", "users"
  add_foreign_key "group_users", "groups"
  add_foreign_key "group_users", "users"
  add_foreign_key "notifications", "users", column: "receiver_id"
  add_foreign_key "sub_comments", "comments"
  add_foreign_key "sub_comments", "users"
  add_foreign_key "ticket_assignments", "groups"
  add_foreign_key "ticket_assignments", "tickets"
  add_foreign_key "ticket_assignments", "users"
  add_foreign_key "tickets", "users", column: "creator_id"
  add_foreign_key "user_functions", "function_systems"
  add_foreign_key "user_functions", "groups"
  add_foreign_key "user_functions", "users"
end
