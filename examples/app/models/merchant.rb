class Merchant < ActiveRecord::Base
  attr_accessible :ppp_access_token, :ppp_access_token_verifier
end
