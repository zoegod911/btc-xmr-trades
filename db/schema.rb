# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_01_16_234517) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "categories", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "title"
    t.string "ancestry"
    t.string "slug"
    t.integer "ancestry_depth"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["slug"], name: "index_categories_on_slug"
    t.index ["title"], name: "index_categories_on_title"
  end

  create_table "global_chat_messages", force: :cascade do |t|
    t.uuid "sender_id", null: false
    t.uuid "global_chat_id", null: false
    t.text "content", null: false
    t.text "pinged_trader_ids", default: [], array: true
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["global_chat_id"], name: "index_global_chat_messages_on_global_chat_id"
    t.index ["pinged_trader_ids"], name: "index_global_chat_messages_on_pinged_trader_ids"
    t.index ["sender_id"], name: "index_global_chat_messages_on_sender_id"
  end

  create_table "global_chats", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.jsonb "present_trader_ids", default: [], null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["present_trader_ids"], name: "index_global_chats_on_present_trader_ids"
  end

  create_table "notifications", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "message", null: false
    t.text "destination_path", null: false
    t.boolean "seen", default: false, null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["message"], name: "index_notifications_on_message"
    t.index ["seen"], name: "index_notifications_on_seen"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "offerings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "seller_id", null: false
    t.integer "coin_type", null: false
    t.decimal "price_per_coin", null: false
    t.decimal "minimum_price", null: false
    t.decimal "maximum_price", null: false
    t.string "target_currency", null: false
    t.uuid "trade_item_id", null: false
    t.integer "minimum_trades_completed", null: false
    t.text "description", null: false
    t.boolean "grey_market", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["coin_type"], name: "index_offerings_on_coin_type"
    t.index ["grey_market"], name: "index_offerings_on_grey_market"
    t.index ["maximum_price"], name: "index_offerings_on_maximum_price"
    t.index ["minimum_price"], name: "index_offerings_on_minimum_price"
    t.index ["minimum_trades_completed"], name: "index_offerings_on_minimum_trades_completed"
    t.index ["price_per_coin"], name: "index_offerings_on_price_per_coin"
    t.index ["target_currency"], name: "index_offerings_on_target_currency"
    t.index ["trade_item_id"], name: "index_offerings_on_trade_item_id"
  end

  create_table "reviews", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "trade_id", null: false
    t.uuid "reviewer_id", null: false
    t.uuid "reviewee_id", null: false
    t.text "content", null: false
    t.boolean "trusted", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["reviewee_id"], name: "index_reviews_on_reviewee_id"
    t.index ["reviewer_id"], name: "index_reviews_on_reviewer_id"
    t.index ["trade_id"], name: "index_reviews_on_trade_id"
    t.index ["trusted"], name: "index_reviews_on_trusted"
  end

  create_table "sessions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "session_id", null: false
    t.text "data"
    t.datetime "last_request_at", default: "2020-01-21 05:41:56", null: false
    t.integer "offensive_requests", default: 0, null: false
    t.boolean "blocklisted", default: false, null: false
    t.boolean "throttled", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["session_id"], name: "index_sessions_on_session_id", unique: true
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end

  create_table "trade_chat_message_attachments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "trade_chat_message_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["trade_chat_message_id"], name: "index_trade_chat_message_attachments_on_trade_chat_message_id"
  end

  create_table "trade_chat_messages", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "sender_id", null: false
    t.uuid "trade_chat_id", null: false
    t.text "content", null: false
    t.boolean "edited", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["edited"], name: "index_trade_chat_messages_on_edited"
    t.index ["sender_id"], name: "index_trade_chat_messages_on_sender_id"
    t.index ["trade_chat_id"], name: "index_trade_chat_messages_on_trade_chat_id"
  end

  create_table "trade_chats", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "pgp_public_key", null: false
    t.text "pgp_private_key", null: false
    t.text "passphrase", null: false
    t.uuid "trade_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["trade_id"], name: "index_trade_chats_on_trade_id"
  end

  create_table "trade_disputes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "opened_by_id", null: false
    t.uuid "against_id", null: false
    t.integer "presiding_moderator_id"
    t.text "claim_details", null: false
    t.text "claim_reason", null: false
    t.uuid "trade_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["against_id"], name: "index_trade_disputes_on_against_id"
    t.index ["opened_by_id"], name: "index_trade_disputes_on_opened_by_id"
    t.index ["presiding_moderator_id"], name: "index_trade_disputes_on_presiding_moderator_id"
    t.index ["trade_id"], name: "index_trade_disputes_on_trade_id"
  end

  create_table "trade_escrows", force: :cascade do |t|
    t.uuid "trade_id", null: false
    t.integer "status", default: 0, null: false
    t.text "coin_address", null: false
    t.jsonb "destination", default: {}, null: false
    t.uuid "release_to_id", null: false
    t.boolean "released", default: false, null: false
    t.decimal "coin_amount", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["coin_amount"], name: "index_trade_escrows_on_coin_amount"
    t.index ["destination"], name: "index_trade_escrows_on_destination"
    t.index ["release_to_id"], name: "index_trade_escrows_on_release_to_id"
    t.index ["released"], name: "index_trade_escrows_on_released"
    t.index ["status"], name: "index_trade_escrows_on_status"
    t.index ["trade_id"], name: "index_trade_escrows_on_trade_id"
  end

  create_table "trade_items", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "category_id", null: false
    t.string "title"
    t.string "slug"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["category_id"], name: "index_trade_items_on_category_id"
    t.index ["slug"], name: "index_trade_items_on_slug"
    t.index ["title"], name: "index_trade_items_on_title"
  end

  create_table "trade_offers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "trade_request_id", null: false
    t.uuid "sender_id", null: false
    t.decimal "coin_amount", null: false
    t.boolean "accepted", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["accepted"], name: "index_trade_offers_on_accepted"
    t.index ["coin_amount"], name: "index_trade_offers_on_coin_amount"
    t.index ["sender_id"], name: "index_trade_offers_on_sender_id"
    t.index ["trade_request_id"], name: "index_trade_offers_on_trade_request_id"
  end

  create_table "trade_requests", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "from_crypto", null: false
    t.string "to_crypto", null: false
    t.decimal "coin_amount", null: false
    t.uuid "trader_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["coin_amount"], name: "index_trade_requests_on_coin_amount"
    t.index ["from_crypto"], name: "index_trade_requests_on_from_crypto"
    t.index ["to_crypto"], name: "index_trade_requests_on_to_crypto"
    t.index ["trader_id"], name: "index_trade_requests_on_trader_id"
  end

  create_table "traders", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "slug", null: false
    t.integer "trust_score", default: 0, null: false
    t.string "wallet_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["slug"], name: "index_traders_on_slug", unique: true
    t.index ["trust_score"], name: "index_traders_on_trust_score"
    t.index ["user_id"], name: "index_traders_on_user_id"
  end

  create_table "trades", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "offering_id", null: false
    t.uuid "buyer_id", null: false
    t.integer "status", null: false
    t.datetime "expires_at", null: false
    t.decimal "locked_coin_price", null: false
    t.decimal "target_amount", null: false
    t.boolean "requested_extension", default: false, null: false
    t.boolean "seller_reviewed", default: false, null: false
    t.boolean "buyer_reviewed", default: false, null: false
    t.text "qr_code_data"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["buyer_id"], name: "index_trades_on_buyer_id"
    t.index ["expires_at"], name: "index_trades_on_expires_at"
    t.index ["locked_coin_price"], name: "index_trades_on_locked_coin_price"
    t.index ["status"], name: "index_trades_on_status"
  end

  create_table "users", force: :cascade do |t|
    t.string "username", null: false
    t.text "crypted_password", null: false
    t.text "salt", null: false
    t.integer "role", default: 0, null: false
    t.integer "default_currency", default: 0, null: false
    t.text "pgp_public_key", null: false
    t.text "mnemonic", null: false
    t.string "invite_code"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "last_login_at"
    t.datetime "last_logout_at"
    t.datetime "last_activity_at"
    t.string "last_login_from_ip_address"
    t.integer "failed_logins_count", default: 0
    t.datetime "lock_expires_at"
    t.string "unlock_token"
    t.index ["default_currency"], name: "index_users_on_default_currency"
    t.index ["last_logout_at", "last_activity_at"], name: "index_users_on_last_logout_at_and_last_activity_at"
    t.index ["mnemonic"], name: "index_users_on_mnemonic", unique: true
    t.index ["role"], name: "index_users_on_role"
    t.index ["unlock_token"], name: "index_users_on_unlock_token"
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "global_chat_messages", "global_chats"
  add_foreign_key "notifications", "users"
  add_foreign_key "offerings", "trade_items"
  add_foreign_key "reviews", "trades"
  add_foreign_key "trade_chat_message_attachments", "trade_chat_messages"
  add_foreign_key "trade_chat_messages", "trade_chats"
  add_foreign_key "trade_chats", "trades"
  add_foreign_key "trade_disputes", "trades"
  add_foreign_key "trade_escrows", "trades"
  add_foreign_key "trade_items", "categories"
  add_foreign_key "trade_offers", "trade_requests"
  add_foreign_key "trade_requests", "traders"
  add_foreign_key "traders", "users"
end
