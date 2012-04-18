require 'openssl'
require 'base64'

module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module XPPAuthorization
      public
      def x_pp_authorization_header url, api_user_id, api_password, access_token, access_token_verifier
        timestamp = Time.now.to_i.to_s
        signature = x_pp_authorization_signature url, api_user_id, api_password, timestamp, access_token, access_token_verifier
        { 'X-PP-AUTHORIZATION' => "token=#{access_token},signature=#{signature},timestamp=#{timestamp}" }
      end

      public
      def x_pp_authorization_signature url, api_user_id, api_password, timestamp, access_token, access_token_verifier
        # no query params, but if there were, this is where they'd go
        query_params = {}
        key = [
          URI.encode(api_password),
          URI.encode(access_token_verifier),
        ].join("&")

        params = query_params.dup.merge({
          "oauth_consumer_key" => api_user_id,
          "oauth_version" => "1.0",
          "oauth_signature_method" => "HMAC-SHA1",
          "oauth_token" => access_token,
          "oauth_timestamp" => timestamp,
        })
        sorted_params = Hash[params.sort]
        sorted_query_string = sorted_params.to_query

        base = [
          "POST",
          URI.encode(url),
          URI.encode(sorted_query_string)
        ].join("&")

        hexdigest = OpenSSL::HMAC.hexdigest('sha1', key, base)
        Base64.encode64(hexdigest).chomp
      end
    end
  end
end
