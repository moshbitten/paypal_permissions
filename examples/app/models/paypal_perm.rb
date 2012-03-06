class PaypalPerm < ActiveRecord::Base
  belongs_to :school, :inverse_of => :paypal_perms

  validates :school, :presence => true
  # validates :request_permissions_ack, :presence => true

  attr_accessible :school, :school_id,
                  :request_permissions_ack, :request_permissions_correlation_id, :request_permissions_request_token,
                  :request_permissions_verifier, :request_permissions_envelope_timestamp,
                  :request_permissions_errors, :request_permissions_raw_response,
                  :request_permissions_callback_ack, :request_permissions_callback_correlation_id, :request_permissions_callback_request_token,
                  :request_permissions_callback_verifier, :request_permissions_callback_envelope_timestamp,
                  :request_permissions_callback_errors, :request_permissions_callback_raw_response,
                  :get_access_token_ack, :get_access_token_correlation_id, :get_access_token_access_token,
                  :get_access_token_verifier, :get_access_token_envelope_timestamp,
                  :get_access_token_errors, :get_access_token_raw_response

  public
  def as_json(opts = {})
    opts ||= {}
    super({ :only => %w[id request_permissions_ack request_permissions_correlation_id request_permissions_request_token
                         request_permissions_verifier request_permissions_envelope_timestamp
                         request_permissions_errors request_permissions_raw_response
                         request_permissions_callback_ack request_permissions_callback_correlation_id request_permissions_callback_request_token
                         request_permissions_callback_verifier request_permissions_callback_envelope_timestamp
                         request_permissions_callback_errors request_permissions_callback_raw_response
                         get_access_token_ack get_access_token_correlation_id get_access_token_access_token
                         get_access_token_verifier get_access_token_envelope_timestamp
                         get_access_token_errors get_access_token_raw_response
                       ] }.merge(opts))
  end
end
