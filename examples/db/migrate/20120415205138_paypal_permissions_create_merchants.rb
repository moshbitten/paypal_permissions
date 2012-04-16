class PaypalPermissionsCreateMerchants < ActiveRecord::Migration
  def change
    create_table(:merchants) do |t|

      # GetAccessToken response fields
      t.string :ppp_access_token
      t.string :ppp_access_token_verifier

      t.timestamps
    end

  end
end
