module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module PaypalPermissions
      module Parsers
        class PersonalDataNVParser < CommonNVParser
          class << self
            def parse nvp_response
              super

              @response[:personal_data] = {}

              pairs = nvp_response.split "&"
              pairs.each do |pair|
                n,v = pair.split "="
                n = CGI.unescape n
                v = CGI.unescape v

                case n

                # envelope
                when /^responseEnvelope/
                  process_envelope_pair n, v

                # successful personal data response
                when /response\.personalData\((\d+)\)\.personalDataKey/
                  key_idx = $1.to_i
                  key = personal_data_mappings[v]

                when /response\.personalData\((\d+)\)\.personalDataValue/
                  val_idx = $1.to_i
                  raise unless key && val_idx != key_idx
                  @response[:personal_data][key] = v

                # error with index
                when /^error\((\d+)\)/
                  process_error_pair n, v

                end
              end
            end
          end
        end
      end
    end
  end
end
