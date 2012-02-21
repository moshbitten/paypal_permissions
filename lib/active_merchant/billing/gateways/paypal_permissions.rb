require 'active_merchant'
require 'uri'
require 'cgi'
require 'openssl'
require 'base64'


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
        request_permissions_headers = {
          'X-PAYPAL-SECURITY-USERID' => options.delete(:login),
          'X-PAYPAL-SECURITY-PASSWORD' => options.delete(:password),
          'X-PAYPAL-SECURITY-SIGNATURE' => options.delete(:signature),
          'X-PAYPAL-APPLICATION-ID' => options.delete(:app_id),
          'X-PAYPAL-REQUEST-DATA-FORMAT' => 'NV',
          'X-PAYPAL-RESPONSE-DATA-FORMAT' => 'NV',
        }
        get_access_token_headers = request_permissions_headers.dup
        @options = {
          :request_permissions_headers => request_permissions_headers,
          :get_access_token_headers => get_access_token_headers,
        }.update(options)
        super
      end

      public
      def request_permissions(callback_url, scope)
        query_string = build_request_permissions_query_string callback_url, scope
        nvp_response = ssl_get "#{request_permissions_url}?#{query_string}", @options[:request_permissions_headers]
        if nvp_response =~ /error\(\d+\)/
          puts "request: #{request_permissions_url}?#{query_string}\n"
          puts "nvp_response: #{nvp_response}\n"
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
          puts "request: #{get_access_token_url}?#{query_string}\n"
          puts "nvp_response: #{nvp_response}\n"
        end
        response = parse_get_access_token_nvp(nvp_response)
      end

      public
      def redirect_user_to_paypal_url token
        template = test? ? URLS[:test][:redirect_user_to_paypal] : URLS[:live][:redirect_user_to_paypal]
        template % token
      end

      public
      def get_access_token_url
        test? ? URLS[:test][:get_access_token] : URLS[:live][:get_access_token]
      end

      public
      def get_permissions_url
        test? ? URLS[:test][:get_permissions] : URLS[:live][:get_permissions]
      end

      private
      URLS = {
        :test => {
          :request_permissions => 'https://svcs.sandbox.paypal.com/Permissions/RequestPermissions',
          :redirect_user_to_paypal => 'https://www.sandbox.paypal.com/cgi-bin/webscr?cmd=_grant-permission&request_token=%s',
          :get_access_token => 'https://svcs.sandbox.paypal.com/Permissions/GetAccessToken',
          :get_permissions => 'https://svcs.sandbox.paypal.com/Permissions/GetPermissions',
        },
        :live => {
          :request_permissions => 'https://svcs.paypal.com/Permissions/RequestPermissions',
          :redirect_user_to_paypal => 'https://www.paypal.com/cgi-bin/webscr?cmd=_grant-permission&request_token=%s',
          :get_access_token => 'https://svcs.paypal.com/Permissions/GetAccessToken',
          :get_permissions => 'https://svcs.sandbox.paypal.com/Permissions/GetPermissions',
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

=begin
      private
      def setup_request_permission
        callback
        scope
      end
=end

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
      def authentication_header url
        timestamp = Time.now.to_i
        signature = authentication_signature url, timestamp
        { 'X-PAYPAL-AUTHORIZATION' => "token=#{access_token}, signature=#{signature}, timeStamp=#{timestamp}" }
      end

      private
      def authentication_signature url, timestamp
        # no query params, but if there were, this is where they'd go
        query_params = {}
        key = [ password, verifier ].join("&")
        params = query_params.dup.merge({
          "oauth_consumer_key" => @options[:request_permissions_headers]['X-PAYPAL-SECURITY-USERID'],
          "oauth_version" => "1.0",
          "oauth_signature_method" => "HMAC-SHA1",
          "oauth_token" => access_token,
          "oauth_timestamp" => timestamp,
        })
        sorted_params = Hash[params.sort]
        sorted_query_string = sorted_params.to_query
        data = [ "POST", url, sorted_query_string ].join("&")  # ? "https://api-3t.sandbox.paypal.com/nvp"
        digest = OpenSSL::Digest::Digest.new('sha1')
        OpenSSL::HMAC.digest(digest, key, data)
        enc = Base64.encode64('Send reinforcements')  # encode per RFC 2045 (not 4648
      end
        

=begin
	public static Map getAuthHeader(String apiUserName, String apiPassword,
			String accessToken, String tokenSecret, HTTPMethod httpMethod,
			String scriptURI,Map queryParams) throws OAuthException {
		
		Map headers=new HashMap();
		String consumerKey = apiUserName;
		String consumerSecretStr = apiPassword;
		String time = String.valueOf(System.currentTimeMillis()/1000);
		
		OAuthSignature oauth = new OAuthSignature(consumerKey,consumerSecretStr);
		if(HTTPMethod.GET.equals(httpMethod) && queryParams != null){
			Iterator itr = queryParams.entrySet().iterator();
		    while (itr.hasNext()) {
		        Map.Entry param = (Map.Entry)itr.next();
		        String key=(String)param.getKey();
		        String value=(String)param.getValue();
		        oauth.addParameter(key,value);
		    }
		  }	
		oauth.setToken(accessToken);
		oauth.setTokenSecret(tokenSecret);
		oauth.setHTTPMethod(httpMethod);
		oauth.setTokenTimestamp(time);
		oauth.setRequestURI(scriptURI);
		//Compute Signature
		String sig = oauth.computeV1Signature();
		
		headers.put("Signature", sig);
		headers.put("TimeStamp", time);
		return headers;
		
	}
=end

      private
      def setup_purchase(options)
        commit('Pay', build_adaptive_payment_pay_request(options))
      end
    end
  end
end
