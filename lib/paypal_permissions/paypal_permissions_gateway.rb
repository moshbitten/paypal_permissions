require 'active_merchant'
require 'active_merchant/billing'
require 'active_merchant/billing/gateway'
require 'paypal_permissions/parsers'
require 'paypal_permissions/x_pp_authorization'
require 'uri'
require 'cgi'


module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    class PaypalPermissionsGateway < ActiveMerchant::Billing::Gateway # :nodoc
      include XPPAuthorization
      include PaypalPermissions::Parsers

      public
      def self.setup
        yield self
      end

      public
      def initialize(options = {})
        requires!(options, :login, :password, :signature, :app_id)
        @login = options.delete(:login)
        @password = options.delete(:password)
        @app_id = options.delete(:app_id)
        @api_signature = options.delete(:signature)
        request_permissions_headers = {
          'X-PAYPAL-SECURITY-USERID' => @login,
          'X-PAYPAL-SECURITY-PASSWORD' => @password,
          'X-PAYPAL-SECURITY-SIGNATURE' => @api_signature,
          'X-PAYPAL-APPLICATION-ID' => @app_id,
          'X-PAYPAL-REQUEST-DATA-FORMAT' => 'NV',
          'X-PAYPAL-RESPONSE-DATA-FORMAT' => 'NV',
        }
        get_access_token_headers = request_permissions_headers.dup
        get_basic_personal_data_headers = lambda { |access_token, access_token_verifier|
          {
            'X-PAYPAL-SECURITY-USERID' => @login,
            'X-PAYPAL-SECURITY-PASSWORD' => @password,
            'X-PAYPAL-SECURITY-SIGNATURE' => @api_signature,
            'X-PAYPAL-APPLICATION-ID' => @app_id,
            'X-PAYPAL-REQUEST-DATA-FORMAT' => 'NV',
            'X-PAYPAL-RESPONSE-DATA-FORMAT' => 'NV',
          }.update(x_pp_authorization_header(get_basic_personal_data_url, @login, @password, access_token, access_token_verifier))
        }
        get_advanced_personal_data_headers = lambda { |access_token, access_token_verifier|
          {
            'X-PAYPAL-SECURITY-USERID' => @login,
            'X-PAYPAL-SECURITY-PASSWORD' => @password,
            'X-PAYPAL-SECURITY-SIGNATURE' => @api_signature,
            'X-PAYPAL-APPLICATION-ID' => @app_id,
            'X-PAYPAL-REQUEST-DATA-FORMAT' => 'NV',
            'X-PAYPAL-RESPONSE-DATA-FORMAT' => 'NV',
          }.update(x_pp_authorization_header(get_advanced_personal_data_url, @login, @password, access_token, access_token_verifier))
        }
        @options = {
          :request_permissions_headers => request_permissions_headers,
          :get_access_token_headers => get_access_token_headers,
          :get_basic_personal_data_headers => get_basic_personal_data_headers,
          :get_advanced_personal_data_headers => get_advanced_personal_data_headers,
        }.update(options)
        super
      end

      public
      def request_permissions(callback_url, scope)
        query_string = build_request_permissions_query_string callback_url, scope
        nvp_response = ssl_get "#{request_permissions_url}?#{query_string}", @options[:request_permissions_headers]
        if nvp_response =~ /error\(\d+\)/
          # puts "request: #{request_permissions_url}?#{query_string}\n"
          # puts "nvp_response: #{nvp_response}\n"
        end
        response = RequestPermissionsNVParser.parse nvp_response
      end

      public
      def request_permissions_url
        test? ? URLS[:test][:request_permissions] : URLS[:live][:request_permissions]
      end

      public
      def get_access_token(request_token, request_token_verifier)
        query_string = build_get_access_token_query_string request_token, request_token_verifier
        nvp_response = ssl_get "#{get_access_token_url}?#{query_string}", @options[:get_access_token_headers]
        if nvp_response =~ /error\(\d+\)/
          # puts "request: #{get_access_token_url}?#{query_string}\n"
          # puts "nvp_response: #{nvp_response}\n"
        end
        response = GetAccessTokenNVParser.parse nvp_response
      end

      public
      def redirect_user_to_paypal_url token
        template = test? ? URLS[:test][:redirect_user_to_paypal] : URLS[:live][:redirect_user_to_paypal]
        template % token
      end

      public
      def get_basic_personal_data(access_token, access_token_verifier)
        body = personal_data_post_body(GetBasicPersonalDataNVParser.personal_data_mappings)
        opts = @options[:get_basic_personal_data_headers].call(access_token, access_token_verifier)
        nvp_response = ssl_post(get_basic_personal_data_url, body, opts)
        if nvp_response =~ /error\(\d+\)/
          # puts "request: #{get_basic_personal_data_url} post_body:#{body}\n"
          # puts "nvp_response: #{nvp_response}\n"
        end
        response = GetBasicPersonalDataNVParser.parse nvp_response
      end

      public
      def get_advanced_personal_data(access_token, access_token_verifier)
        body = personal_data_post_body(GetAdvancedPersonalDataNVParser.personal_data_mappings)
        opts = @options[:get_advanced_personal_data_headers].call(access_token, access_token_verifier)
        nvp_response = ssl_post(get_advanced_personal_data_url, body, opts)
        if nvp_response =~ /error\(\d+\)/
          # puts "request: #{get_advanced_personal_data_url} post_body:#{body}\n"
          # puts "nvp_response: #{nvp_response}\n"
        end
        response = GetAdvancedPersonalDataNVParser.parse nvp_response
      end

      public
      def get_access_token_url
        test? ? URLS[:test][:get_access_token] : URLS[:live][:get_access_token]
      end

      public
      def get_permissions_url
        test? ? URLS[:test][:get_permissions] : URLS[:live][:get_permissions]
      end

      public
      def get_basic_personal_data_url
        test? ? URLS[:test][:get_basic_personal_data] : URLS[:live][:get_basic_personal_data]
      end

      public
      def get_advanced_personal_data_url
        test? ? URLS[:test][:get_advanced_personal_data] : URLS[:live][:get_advanced_personal_data]
      end

      private
      URLS = {
        :test => {
          :request_permissions => 'https://svcs.sandbox.paypal.com/Permissions/RequestPermissions',
          :redirect_user_to_paypal => 'https://www.sandbox.paypal.com/cgi-bin/webscr?cmd=_grant-permission&request_token=%s',
          :get_access_token => 'https://svcs.sandbox.paypal.com/Permissions/GetAccessToken',
          :get_permissions => 'https://svcs.sandbox.paypal.com/Permissions/GetPermissions',
          :get_basic_personal_data => 'https://svcs.sandbox.paypal.com/Permissions/GetBasicPersonalData',
          :get_advanced_personal_data => 'https://svcs.sandbox.paypal.com/Permissions/GetAdvancedPersonalData',
        },
        :live => {
          :request_permissions => 'https://svcs.paypal.com/Permissions/RequestPermissions',
          :redirect_user_to_paypal => 'https://www.paypal.com/cgi-bin/webscr?cmd=_grant-permission&request_token=%s',
          :get_access_token => 'https://svcs.paypal.com/Permissions/GetAccessToken',
          :get_permissions => 'https://www.paypal.com/Permissions/GetPermissions',
          :get_basic_personal_data => 'https://www.paypal.com/Permissions/GetBasicPersonalData',
          :get_advanced_personal_data => 'https://www.paypal.com/Permissions/GetAdvancedPersonalData',
        }
      }

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
      def build_get_access_token_query_string(request_token, verifier)
        "requestEnvelope.errorLanguage=en_US&token=#{request_token}&verifier=#{verifier}"
      end

      private
      def personal_data_post_body(personal_data_mappings)
        body = ""
        personal_data_mappings.keys.each_with_index do |v, idx|
          body += "attributeList.attribute(#{idx})=#{v}&"
        end
        body += "requestEnvelope.errorLanguage=en_US"
      end


=begin
      private
      def setup_purchase(options)
        commit('Pay', build_adaptive_payment_pay_request(options))
      end
=end
    end
  end
end
