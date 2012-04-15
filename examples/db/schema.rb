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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120415205138) do

  create_table "merchants", :force => true do |t|
    t.string   "email"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "full_name"
    t.string   "country"
    t.string   "payer_id"
    t.string   "street1"
    t.string   "street2"
    t.string   "city"
    t.string   "state"
    t.string   "postal_code_string"
    t.string   "phone"
    t.string   "birth_date"
    t.string   "request_permissions_ack"
    t.string   "request_permissions_correlation_id"
    t.string   "request_permissions_request_token"
    t.datetime "request_permissions_envelope_timestamp"
    t.text     "request_permissions_errors"
    t.text     "request_permissions_raw_response"
    t.string   "request_permissions_callback_ack"
    t.string   "request_permissions_callback_correlation_id"
    t.string   "request_permissions_callback_verifier"
    t.datetime "request_permissions_callback_envelope_timestamp"
    t.text     "request_permissions_callback_errors"
    t.text     "request_permissions_callback_raw_response"
    t.string   "get_access_token_ack"
    t.string   "get_access_token_correlation_id"
    t.string   "get_access_token_access_token"
    t.string   "get_access_token_verifier"
    t.datetime "get_access_token_envelope_timestamp"
    t.text     "get_access_token_errors"
    t.text     "get_access_token_raw_response"
    t.datetime "created_at",                                      :null => false
    t.datetime "updated_at",                                      :null => false
  end

  add_index "merchants", ["get_access_token_access_token"], :name => "index_merchants_on_get_access_token_access_token"
  add_index "merchants", ["request_permissions_request_token"], :name => "index_merchants_on_request_permissions_request_token"

end
