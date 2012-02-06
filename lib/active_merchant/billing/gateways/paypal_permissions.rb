require 'active_merchant'
require 'uri'
require 'cgi'

module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    class PaypalPermissionsGateway < Gateway # :nodoc
      public
      def self.setup
        yield self
      end

      public
      def initialize(options = {})
        requires!(options, :login, :password, :signature, :app_id)
        headers = {
          'X-PAYPAL-SECURITY-USERID' => options.delete(:login),
          'X-PAYPAL-SECURITY-PASSWORD' => options.delete(:password),
          'X-PAYPAL-SECURITY-SIGNATURE' => options.delete(:signature),
          'X-PAYPAL-APPLICATION-ID' => options.delete(:app_id),
          'X-PAYPAL-REQUEST-DATA-FORMAT' => 'NV',
          'X-PAYPAL-RESPONSE-DATA-FORMAT' => 'NV',
        }
        @options = {
          :headers => headers,
        }.update(options)
        super
      end

      public
      def request_permissions(callback_url, scope)
        query_string = build_request_permissions_query_string callback_url, scope
        nvp_response = ssl_get "#{request_permissions_url}?#{query_string}", @options[:headers]
        if nvp_response =~ /error\(\d+\)/
          puts "request: #{request_permissions_url}?#{query_string}\n"
          puts "nvp_response: #{nvp_response}\n"
        end
        response = parse_request_permissions_nvp(nvp_response)
      end

      private
      URLS = {
        :test => {
          :request_permissions => 'https://svcs.sandbox.paypal.com/Permissions/RequestPermissions',
          :get_access_token => 'https://svcs.sandbox.paypal.com/Permissions/GetAccessToken',
          :get_permissions => 'https://svcs.sandbox.paypal.com/Permissions/GetPermissions',
        },
        :live => {
          :request_permissions => 'https://svcs.paypal.com/Permissions/RequestPermissions',
          :get_access_token => 'https://svcs.paypal.com/Permissions/GetAccessToken',
          :get_permissions => 'https://svcs.sandbox.paypal.com/Permissions/GetPermissions',
        }
      }

      private
      def request_permissions_url
        test? ? URLS[:test][:request_permissions] : URLS[:live][:request_permissions]
      end

      private
      def build_request_permissions_query_string(callback_url, scope)
        scopes_query = build_scopes_query_string(scope)
        "requestEnvelope.errorLanguage=en_US&#{scopes_query}&callback=#{URI.encode(callback_url)}"
      end

      private
      def build_scopes_query_string(scope)
        if scope.is_a? String
          scopes = scope.split(',')
        elsif scope.is_a? Array
          scopes = scope
        else
          scopes = []
        end
        scopes.collect{ |s| "scope=#{URI.encode(s.to_s.strip.upcase)}" }.join("&")
      end

      private
      def setup_request_permission
        callback
        scope
      end

      private
      def parse_request_permissions_nvp(nvp)
        response = {
          :errors => [
          ],
        }
        pairs = nvp.split "&"
        pairs.each do |pair|
          n,v = pair.split "="
          n = CGI.unescape n
          v = CGI.unescape v
          case n
          when "responseEnvelope.timestamp"
            response[:timestamp] = v
          when "responseEnvelope.ack"
            response[:ack] = v
=begin
# Client should implement these with logging...
            case v
            when "Success"
            when "Failure"
            when "Warning"
            when "SuccessWithWarning"
            when "FailureWithWarning"
            end
=end
          when "responseEnvelope.correlationId"
            response[:correlation_id] = v
          when "responseEnvelope.build"
            # do nothing
          when "token"
            response[:token] = v
          when /^error\((?<error_idx>\d+)\)/
            error_idx = error_idx.to_i
            if response[:errors].length <= error_idx
              response[:errors] << { :parameters => [] }
              raise if response[:errors].length <= error_idx
            end
            case n
            when /^error\(\d+\)\.errorId$/
              response[:errors][error_idx][:error_id] = v
=begin
# Client should implement these with logging. PayPal doesn't distinguish
# between errors which can be corrected by the user and errors which need
# to be corrected by a developer or merchant, say, in configuration.
#             case v
#             when "520002"
#             when
=end            
            when /^error\(\d+\)\.domain$/
              response[:errors][error_idx][:domain] = v
            when /^error\(\d+\)\.subdomain$/
              response[:errors][error_idx][:subdomain] = v
            when /^error\(\d+\)\.severity$/
              response[:errors][error_idx][:severity] = v
            when /^error\(\d+\)\.category$/
              response[:errors][error_idx][:category] = v
            when /^error\(\d+\)\.message$/
              response[:errors][error_idx][:message] = v
            when /^error\(\d+\)\.parameter\((?<parameter_idx>\d+)\)$/
              parameter_idx = parameter_idx.to_i
              if response[:errors][error_idx][:parameters].length <= parameter_idx
                response[:errors][error_idx][:parameters] << {}
                raise if response[:errors][error_idx][:parameters].length <= parameter_idx
              end
              response[:errors][error_idx][:parameters][parameter_idx] = v
            end
          end
        end
        response
      end

      private
      def setup_purchase(options)
        commit('Pay', build_adaptive_payment_pay_request(options))
      end
    end
  end
end
