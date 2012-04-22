module ActiveMerchant
  module Billing
    module PaypalPermissions
      module Parsers
        class CommonNVParser
          class << self
            def parse nvp_response
              @response = {
                :raw_response => nvp_response,
                :errors => [
                ],
              }
            end

            def process_envelope_pair n, v
              case n
              when "responseEnvelope.timestamp"
                @response[:timestamp] = v
              when "responseEnvelope.ack"
                @response[:ack] = v
              when "responseEnvelope.correlationId"
                @response[:correlation_id] = v
              when "responseEnvelope.build"
                # do nothing
              end
            end

            def process_error_idx error_idx
              if @response[:errors].length <= error_idx
                @response[:errors] << { :parameters => [] }
                raise if @response[:errors].length <= error_idx
              end
            end

            def process_error_pair n, v
              n =~ /^error\((\d+)\)/
              error_idx = $1.to_i
              process_error_idx error_idx

              case n
              when /^error\(\d+\)\.errorId$/
                @response[:errors][error_idx][:error_id] = v
              when /^error\(\d+\)\.domain$/
                @response[:errors][error_idx][:domain] = v
              when /^error\(\d+\)\.subdomain$/
                @response[:errors][error_idx][:subdomain] = v
              when /^error\(\d+\)\.severity$/
                @response[:errors][error_idx][:severity] = v
              when /^error\(\d+\)\.category$/
                @response[:errors][error_idx][:category] = v
              when /^error\(\d+\)\.message$/
                @response[:errors][error_idx][:message] = v
              when /^error\(\d+\)\.parameter\((\d+)\)$/
                parameter_idx = $1.to_i  # yes, $1, I've escaped the parentheses around the first \d match
                if @response[:errors][error_idx][:parameters].length <= parameter_idx
                  @response[:errors][error_idx][:parameters] << {}
                  raise if @response[:errors][error_idx][:parameters].length <= parameter_idx
                end
                @response[:errors][error_idx][:parameters][parameter_idx] = v
              end
            end
          end
        end
      end
    end
  end
end
