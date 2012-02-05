require 'active_merchant'
require 'uri'

module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    class PaypalPermissionsGateway < Gateway # :nodoc
      def self.setup
        yield self
      end

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

      def initialize(options = {})
        requires!(options, :login, :password, :signature, :app_id)
        headers = {
          'X-PAYPAL-SECURITY-USERID' => options.delete(:login),
          'X-PAYPAL-SECURITY-PASSWORD' => options.delete(:password),
          'X-PAYPAL-SECURITY-SIGNATURE' => options.delete(:api_signature),
          'X-PAYPAL-APPLICATION-ID' => options.delete(:app_id),
          'X-PAYPAL-REQUEST-DATA-FORMAT' => 'NV',
          'X-PAYPAL-RESPONSE-DATA-FORMAT' => 'NV',
        }
        @options = {
          :headers => headers,
        }.update(options)
        super
      end

      def request_permissions_url
        test? ? URLS[:test][:request_permissions] : URLS[:live][:request_permissions]
      end

      def request_permissions(callback_url, scope = "EXPRESS_CHECKOUT,DIRECT_PAYMENT")
        ssl_get request_permissions_url, @options[:headers]

        commit build_request_permissions_query_string(callback_url, scope)

      end

      def build_request_permissions_query_string(callback_url, scope)
        "requestEnvelope.errorLanguage=en_US&scope=#{scope}&callback=#{URI.escape(callback_url)}"
      end

      def setup_request_permission
        callback
        scope
      end

      def parse_request_permissions_nvp(nvp)
        # response = {}
        # error_messages = []
        # error_codes = []
        response = {
          :envelope => {
            :timestamp => nil,
            :ack => nil,
            :correlationId => nil,
            :build => nil,
          },
          :errors => [
          ],
        }
        pairs = nvp.split "&"
        pairs.each do |n,v|
          n = URI.decode n
          v = URI.decode v
          case n
          when "responseEnvelope.timestamp"
            response[:envelope][:timestamp] = v
          when "responseEnvelope.ack"
            response[:envelope][:ack] = v
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
          when "responseEnvelope.build"
            # PayPal API at its worst, do nothing
          when "token"
          when /^error\(\d+\).errorId$/
=begin
# Client should implement these with logging. PayPal doesn't distinguish
# between errors which can be corrected by the user and errors which need
# to be corrected by a developer or merchant, say, in configuration.
#             case v
#             when "520002"
#             when
=end            
          when /^error\(\d+\).domain$/
          when /^error\(\d+\).subdomain$/
          when /^error\(\d+\).severity$/
          when /^error\(\d+\).category$/
          when /^error\(\d+\).message$/
          when /^error\(\d+\).parameter\(\d+\)$/
          end
        end
      end

      def setup_purchase(options)
        commit('Pay', build_adaptive_payment_pay_request(options))
      end
    end
  end
end
