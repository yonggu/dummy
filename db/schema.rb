# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20150223121552) do

  create_table "analysis_config_items", force: :cascade do |t|
    t.integer  "analysis_config_id", limit: 4
    t.string   "name",               limit: 255
    t.string   "value",              limit: 255
    t.string   "options",            limit: 255
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  add_index "analysis_config_items", ["analysis_config_id"], name: "index_analysis_config_items_on_analysis_config_id", using: :btree

  create_table "analysis_configs", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.text     "description", limit: 65535
    t.string   "guide",       limit: 255
    t.boolean  "enabled",     limit: 1
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.string   "category",    limit: 255
  end

  create_table "build_items", force: :cascade do |t|
    t.integer  "build_id",                    limit: 4
    t.text     "output",                      limit: 4294967295
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.integer  "projects_analysis_config_id", limit: 4
    t.boolean  "passed",                      limit: 1
  end

  add_index "build_items", ["build_id"], name: "index_build_items_on_build_id", using: :btree
  add_index "build_items", ["projects_analysis_config_id"], name: "index_build_items_on_projects_analysis_config_id", using: :btree

  create_table "builds", force: :cascade do |t|
    t.datetime "started_at"
    t.datetime "finished_at"
    t.integer  "project_id",          limit: 4
    t.string   "aasm_state",          limit: 255
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
    t.text     "output",              limit: 4294967295
    t.string   "branch",              limit: 255
    t.string   "last_commit_id",      limit: 255
    t.string   "author",              limit: 255
    t.text     "last_commit_message", limit: 65535
    t.string   "author_email",        limit: 255,        default: ""
    t.boolean  "success",             limit: 1
    t.string   "job_id",              limit: 255
  end

  add_index "builds", ["project_id"], name: "index_builds_on_project_id", using: :btree

  create_table "changed_files", force: :cascade do |t|
    t.string   "path",              limit: 255
    t.integer  "build_item_id",     limit: 4
    t.text     "original_content",  limit: 65535
    t.text     "corrected_content", limit: 65535
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.text     "diff",              limit: 65535
  end

  add_index "changed_files", ["build_item_id"], name: "index_changed_files_on_build_item_id", using: :btree

  create_table "hipchat_configs", force: :cascade do |t|
    t.string   "auth_token", limit: 255
    t.string   "room",       limit: 255
    t.integer  "project_id", limit: 4
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "hipchat_configs", ["project_id"], name: "index_hipchat_configs_on_project_id", using: :btree

  create_table "identities", force: :cascade do |t|
    t.string   "uid",                 limit: 255
    t.string   "provider",            limit: 255
    t.integer  "user_id",             limit: 4
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.string   "access_token",        limit: 255
    t.string   "access_token_secret", limit: 255
  end

  add_index "identities", ["user_id"], name: "index_identities_on_user_id", using: :btree

  create_table "invitations", force: :cascade do |t|
    t.integer  "project_id", limit: 4
    t.string   "email",      limit: 255
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.string   "token",      limit: 255
    t.integer  "inviter_id", limit: 4
    t.integer  "invitee_id", limit: 4
    t.boolean  "accepted",   limit: 1,   default: false, null: false
  end

  add_index "invitations", ["email"], name: "index_invitations_on_email", using: :btree
  add_index "invitations", ["project_id"], name: "index_invitations_on_project_id", using: :btree

  create_table "memberships", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.integer  "project_id", limit: 4
    t.integer  "role",       limit: 4
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  create_table "offenses", force: :cascade do |t|
    t.string   "severity",        limit: 255
    t.text     "message",         limit: 65535
    t.boolean  "corrected",       limit: 1
    t.integer  "line",            limit: 4
    t.integer  "column",          limit: 4
    t.integer  "length",          limit: 4
    t.integer  "build_item_id",   limit: 4
    t.integer  "changed_file_id", limit: 4
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  add_index "offenses", ["build_item_id"], name: "index_offenses_on_build_item_id", using: :btree
  add_index "offenses", ["changed_file_id"], name: "index_offenses_on_changed_file_id", using: :btree

  create_table "project_config_descs", force: :cascade do |t|
    t.string   "title",       limit: 255
    t.text     "desc",        limit: 65535
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.string   "style_guide", limit: 255
  end

  add_index "project_config_descs", ["title"], name: "index_project_config_descs_on_title", using: :btree

  create_table "project_configs", force: :cascade do |t|
    t.text     "content",    limit: 65535
    t.integer  "project_id", limit: 4
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "project_configs", ["project_id"], name: "index_project_configs_on_project_id", using: :btree

  create_table "projects", force: :cascade do |t|
    t.string   "name",                  limit: 255
    t.text     "origin_report_content", limit: 4294967295
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "absolute_path",         limit: 255
    t.string   "repository_url",        limit: 255
    t.boolean  "private",               limit: 1
    t.boolean  "fork",                  limit: 1
    t.string   "git_url",               limit: 255
    t.string   "ssh_url",               limit: 255
    t.boolean  "enabled",               limit: 1,          default: false
    t.string   "owner_login",           limit: 255
    t.integer  "hook_id",               limit: 4
    t.text     "ssh_public_key",        limit: 65535
    t.integer  "deploy_key_id",         limit: 4
    t.boolean  "send_mail",             limit: 1,          default: true
    t.string   "owner_uid",             limit: 255
    t.string   "type",                  limit: 255
    t.text     "included_files",        limit: 65535
    t.text     "excluded_files",        limit: 65535
  end

  create_table "projects_analysis_config_items", force: :cascade do |t|
    t.integer  "projects_analysis_config_id", limit: 4
    t.integer  "analysis_config_item_id",     limit: 4
    t.string   "value",                       limit: 255
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
  end

  add_index "projects_analysis_config_items", ["analysis_config_item_id"], name: "by_analysis_config_item", using: :btree
  add_index "projects_analysis_config_items", ["projects_analysis_config_id"], name: "by_projects_analysis_config", using: :btree

  create_table "projects_analysis_configs", force: :cascade do |t|
    t.integer  "project_id",         limit: 4
    t.integer  "analysis_config_id", limit: 4
    t.boolean  "enabled",            limit: 1
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "projects_analysis_configs", ["analysis_config_id"], name: "index_projects_analysis_configs_on_analysis_config_id", using: :btree
  add_index "projects_analysis_configs", ["project_id"], name: "index_projects_analysis_configs_on_project_id", using: :btree

  create_table "pull_requests", force: :cascade do |t|
    t.integer  "user_id",       limit: 4
    t.time     "sent_at"
    t.integer  "build_item_id", limit: 4
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.boolean  "push_directly", limit: 1
  end

  add_index "pull_requests", ["build_item_id"], name: "index_pull_requests_on_build_item_id", using: :btree
  add_index "pull_requests", ["user_id"], name: "index_pull_requests_on_user_id", using: :btree

  create_table "slack_configs", force: :cascade do |t|
    t.string  "webhook_url", limit: 255
    t.integer "project_id",  limit: 4
  end

  add_index "slack_configs", ["project_id"], name: "index_slack_configs_on_project_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.string   "name",                   limit: 255
    t.string   "encrypted_password",     limit: 255, default: "", null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,   default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  add_foreign_key "invitations", "projects"
  add_foreign_key "slack_configs", "projects"
end
