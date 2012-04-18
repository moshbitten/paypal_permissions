require 'paypal_permissions/parsers/personal_data'

module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module PaypalPermissions
      module Parsers
        class GetAdvancedPersonalDataNVParser < PersonalDataNVParser
          class << self
            def personal_data_mappings
              {
                "http://axschema.org/birthDate" => :birthdate,
                "http://schema.openid.net/contact/street1" => :street1,
                "http://schema.openid.net/contact/street2" => :street2,
                "http://axschema.org/contact/city/home" => :city,
                "http://axschema.org/contact/state/home" => :state,
                "http://axschema.org/contact/postalCode/home" => :postal_code,
                "http://axschema.org/contact/phone/default" => :phone,
              }
            end
          end
        end
      end
    end
  end
end

