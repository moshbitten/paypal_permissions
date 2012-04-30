require 'cgi'
require 'openssl'
require 'base64'


class Hash
  def to_paypal_permissions_query
    collect do |key, value|
      "#{key}=#{value}"
    end.sort * '&'
  end
end

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
          paypal_encode(api_password),
          paypal_encode(access_token_verifier),
        ].join("&")

        params = query_params.dup.merge({
          "oauth_consumer_key" => api_user_id,
          "oauth_version" => "1.0",
          "oauth_signature_method" => "HMAC-SHA1",
          "oauth_token" => access_token,
          "oauth_timestamp" => timestamp,
        })
        sorted_query_string = params.to_paypal_permissions_query
        puts "paypal_encoded_sorted_query_string:#{paypal_encode(sorted_query_string)}"

        base = [
          "POST",
          paypal_encode(url),
          paypal_encode(sorted_query_string)
        ].join("&")
        base = base.gsub /%([0-9A-F])([0-9A-F])/ do
          "%#{$1.downcase}#{$2.downcase}"  # hack to match PayPal Java SDK bit for bit
        end

        digest = OpenSSL::HMAC.digest('sha1', key, base)
        Base64.encode64(digest).chomp
      end

      # The PayPalURLEncoder java class percent encodes everything other than 'a-zA-Z0-9 _'.
      # Then it converts ' ' to '+'.
      # Ruby's CGI.encode takes care of the ' ' and '*' to satisfy PayPal
      # (but beware, URI.encode percent encodes spaces, and does nothing with '*').
      # Finally, CGI.encode does not encode '.-', which we need to do here.
      def paypal_encode str
        s = str.dup
        CGI.escape(s).gsub('.', '%2E').gsub('-', '%2D')
      end
    end
  end
end
