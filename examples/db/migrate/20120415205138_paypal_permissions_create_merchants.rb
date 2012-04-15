class PaypalPermissionsCreateMerchants < ActiveRecord::Migration
  def change
    create_table(:merchants) do |t|
      t.string :email
      t.string :first_name
      t.string :last_name
      t.string :full_name
      t.string :country
      t.string :payer_id
      t.string :street1
      t.string :street2
      t.string :city
      t.string :state
      t.string :postal_code_string
      t.string :phone
      t.string :birth_date

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

    add_index :merchants, :request_permissions_request_token
    add_index :merchants, :get_access_token_access_token
  end
end
