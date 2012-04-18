require 'paypal_permissions/parsers/personal_data'

module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module PaypalPermissions
      module Parsers
        class GetBasicPersonalDataNVParser < PersonalDataNVParser
          class << self
            def personal_data_mappings
              {
                "http://axschema.org/contact/country/home" => :country,
                "http://axschema.org/contact/email" => :email,
                "http://axschema.org/namePerson/first" => :first_name,
                "http://axschema.org/namePerson/last" => :last_name,
                "http://schema.openid.net/contact/fullname" => :full_name,
                "https://www.paypal.com/webapps/auth/schema/payerID" => :payer_id,
              }
            end
          end
        end
      end
    end
  end
end

