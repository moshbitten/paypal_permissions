module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module PaypalPermissions
      module Parsers
        class GetAccessTokenNVParser < CommonNVParser
          class << self
            def parse nvp_response
              super

              pairs = nvp_response.split "&"
              pairs.each do |pair|
                n,v = pair.split "="
                v ||= ""
                n = CGI.unescape n
                v = CGI.unescape v

                case n

                # envelope
                when /^responseEnvelope/
                  process_envelope_pair n, v

                # successful token response
                when "token"
                  @response[:token] = v
                when "tokenSecret"
                  @response[:token_secret] = v

                # error with index
                when /^error\((\d+)\)/
                  process_error_pair n, v

                end
              end
              @response
            end
          end
        end
      end
    end
  end
end

