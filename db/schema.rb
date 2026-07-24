ActiveRecord::Schema[8.1].define(version: 2026_07_16_044645) do

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "password_digest", null: false
    t.string "token", null: false
    t.datetime "updated_at", null: false
    t.string "username", null: false
    t.index ["token"], name: "index_users_on_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end
end