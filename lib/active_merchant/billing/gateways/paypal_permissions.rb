require 'active_merchant'
require 'active_merchant/billing'
require 'active_merchant/billing/gateway'
require 'uri'
require 'cgi'
require 'openssl'
require 'base64'
require 'active_merchant/billing/gateways/paypal_permissions/x_pp_authorization'


module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    class PaypalPermissionsGateway < Gateway # :nodoc
      include XPPAuthorization

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
          }.update(x_pp_authorization_header(get_basic_personal_data_url, access_token, access_token_verifier))
        }
        get_advanced_personal_data_headers = lambda { |access_token, access_token_verifier|
          {
            'X-PAYPAL-SECURITY-USERID' => @login,
            'X-PAYPAL-SECURITY-PASSWORD' => @password,
            'X-PAYPAL-SECURITY-SIGNATURE' => @api_signature,
            'X-PAYPAL-APPLICATION-ID' => @app_id,
            'X-PAYPAL-REQUEST-DATA-FORMAT' => 'NV',
            'X-PAYPAL-RESPONSE-DATA-FORMAT' => 'NV',
          }.update(x_pp_authorization_header(get_advanced_personal_data_url, access_token, access_token_verifier))
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
        response = parse_request_permissions_nvp(nvp_response)
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
        response = parse_get_access_token_nvp(nvp_response)
      end

      public
      def redirect_user_to_paypal_url token
        template = test? ? URLS[:test][:redirect_user_to_paypal] : URLS[:live][:redirect_user_to_paypal]
        template % token
      end

      def basic_personal_data_mappings
        {
          "http://axschema.org/contact/country/home" => :country,
          "http://axschema.org/contact/email" => :email,
          "http://axschema.org/namePerson/first" => :first_name,
          "http://axschema.org/namePerson/last" => :last_name,
          "http://schema.openid.net/contact/fullname" => :full_name,
          "https://www.paypal.com/webapps/auth/schema/payerID" => :payer_id,
        }
      end

      def advanced_personal_data_mappings
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

      public
      def get_basic_personal_data(access_token, access_token_verifier)
        body = personal_data_post_body(basic_personal_data_mappings)
        opts = @options[:get_basic_personal_data_headers].call(access_token, access_token_verifier)
        nvp_response = ssl_post(get_basic_personal_data_url, body, opts)
        if nvp_response =~ /error\(\d+\)/
          # puts "request: #{get_basic_personal_data_url} post_body:#{body}\n"
          # puts "nvp_response: #{nvp_response}\n"
        end
        response = parse_personal_data_nvp(nvp_response, basic_personal_data_mappings)
      end

      public
      def get_advanced_personal_data(access_token, access_token_verifier)
        body = personal_data_post_body(advanced_personal_data_mappings)
        opts = @options[:get_advanced_personal_data_headers].call(access_token, access_token_verifier)
        nvp_response = ssl_post(get_advanced_personal_data_url, body, opts)
        if nvp_response =~ /error\(\d+\)/
          # puts "request: #{get_advanced_personal_data_url} post_body:#{body}\n"
          # puts "nvp_response: #{nvp_response}\n"
        end
        response = parse_personal_data_nvp(nvp_response, advanced_personal_data_mappings)
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
          when /^error\((\d+)\)/
            error_idx = $1.to_i
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
            when /^error\(\d+\)\.parameter\((\d+)\)$/
              parameter_idx = $1.to_i
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
      def parse_get_access_token_nvp(nvp)
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
          when "tokenSecret"
            response[:tokenSecret] = v
          when /^error\((\d+)\)/
            error_idx = $1.to_i
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
            when /^error\(\d+\)\.parameter\((\d+)\)$/
              parameter_idx = $1.to_i
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
      def parse_personal_data_nvp(nvp, personal_data_mappings)
        response = {
          :raw_response => nvp,
          :errors => [
          ],
          :personal_data => {
          }
        }
begin
        key = nil
        key_idx = nil
        pairs = nvp.split "&"
        pairs.each do |pair|
          n,v = pair.split "="
          v = "" if v.nil?
          n = CGI.unescape n
          v = CGI.unescape v
          case n
          when "responseEnvelope.timestamp"
            response[:timestamp] = v
          when "responseEnvelope.ack"
            response[:ack] = v
          when "responseEnvelope.correlationId"
            response[:correlation_id] = v
          when "responseEnvelope.build"
            # do nothing

          when /response\.personalData\((\d+)\)\.personalDataKey/
            key_idx = $1.to_i
            key = personal_data_mappings[v]
=begin
            case v
            when "http://axschema.org/contact/country/home"
              key = :country
            when "http://axschema.org/contact/email"
              key = :email
            when "http://axschema.org/namePerson/first"
              key = :first_name
            when "http://axschema.org/namePerson/last"
              key = :last_name
            when "http://schema.openid.net/contact/fullname"
              key = :full_name
            when "https://www.paypal.com/webapps/auth/schema/payerID"
              key = :payer_id
            end
=end

          when /response\.personalData\((\d+)\)\.personalDataValue/
            val_idx = $1.to_i
            if !key
              # puts "key:#{key} is nil for v:#{v}"
            elsif val_idx != key_idx
              # puts "key_idx:#{key_idx} is out of sync with val_idx:#{val_idx} for key:#{key}"
            else
              response[:personal_data][key] = v
            end

          when /^error\((\d+)\)/
            error_idx = $1.to_i
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
            when /^error\(\d+\)\.parameter\((\d+)\)$/
              parameter_idx = $1.to_i
              if response[:errors][error_idx][:parameters].length <= parameter_idx
                response[:errors][error_idx][:parameters] << {}
                raise if response[:errors][error_idx][:parameters].length <= parameter_idx
              end
              response[:errors][error_idx][:parameters][parameter_idx] = v
            end
          end
        end
rescue
  response[:errors][:unknown_error] << nvp.inspect
end
        response
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
