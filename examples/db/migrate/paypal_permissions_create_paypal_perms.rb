class PaypalPermissionsCreatePaypalPerms < ActiveRecord::Migration
  def change
    create_table(:paypal_perms) do |t|
      t.integer "school_id", :null => false

      # RequestPermissions response fields
      t.string :request_permissions_ack
      t.string :request_permissions_correlation_id
      t.string :request_permissions_request_token
      t.datetime :request_permissions_envelope_timestamp
      t.text :request_permissions_errors
      t.text :request_permissions_raw_response

      # RequestPermissions callback fields
      t.string :request_permissions_callback_ack
      t.string :request_permissions_callback_correlation_id
      t.string :request_permissions_callback_verifier
      t.datetime :request_permissions_callback_envelope_timestamp
      t.text :request_permissions_callback_errors
      t.text :request_permissions_callback_raw_response
      
      # GetAccessToken response fields
      t.string :get_access_token_ack
      t.string :get_access_token_correlation_id
      t.string :get_access_token_access_token
      t.string :get_access_token_verifier
      t.datetime :get_access_token_envelope_timestamp
      t.text :get_access_token_errors
      t.text :get_access_token_raw_response

      t.timestamps
    end

    add_index :paypal_perms, :request_permissions_request_token
    add_index :paypal_perms, :get_access_token_access_token
  end
end
