class MerchantsController < ApplicationController
  def show
    @merchant = Merchant.first
    @merchant = Merchant.create unless @merchant
  end

  def update
    callback_url = URI.encode(merchants_request_permissions_callback_url)
    permissions = 'EXPRESS_CHECKOUT,DIRECT_PAYMENT,ACCESS_BASIC_PERSONAL_DATA,ACCESS_ADVANCED_PERSONAL_DATA'
    paypal_response = ::PAYPAL_PERMISSIONS_GATEWAY.request_permissions callback_url, permissions
    if paypal_response[:ack] == 'Success'
      request_token = paypal_response[:token]
      session[:merchant_id] = params[:id]
      session[:request_token] = request_token
      # paypal_perms.update_attribute :request_permissions_request_token, request_token
      url = ::PAYPAL_PERMISSIONS_GATEWAY.redirect_user_to_paypal_url(request_token)
      redirect_to url
    else
      render :text => paypal_response.inspect
      # handle error
    end
  end

  def request_permissions_callback
    # merchant = Merchant.find_by_request_permissions_request_token params[:request_token]
    # merchant.update_attribute :request_permissions_callback_verifier, params[:verification_code]
    merchant = Merchant.find session[:merchant_id]
    session[:request_token_verifier] = params[:verification_code]
    get_access_token
    redirect_to merchant_path(merchant)
  end

  def get_access_token
    # request_token = merchant.request_permissions_request_token
    # verifier = merchant.request_permissions_callback_verifier
    merchant = Merchant.find session[:merchant_id]
    request_token = session[:request_token]
    verifier = session[:request_token_verifier]
    paypal_response = ::PAYPAL_PERMISSIONS_GATEWAY.get_access_token request_token, verifier
    if paypal_response[:ack] == 'Success'
      merchant.update_attributes({
        :ppp_access_token => paypal_response[:token],
        :ppp_access_token_verifier => paypal_response[:tokenSecret],
      })
    else
      # handle error
    end
  end

  def get_basic_personal_data merchant
    access_token = merchant.ppp_access_token
    verifier = merchant.ppp_access_token_verifier
    ::PAYPAL_PERMISSIONS_GATEWAY.get_basic_personal_data(access_token, verifier)
  end

  def get_advanced_personal_data merchant
    access_token = merchant.ppp_access_token
    verifier = merchant.ppp_access_token_verifier
    ::PAYPAL_PERMISSIONS_GATEWAY.get_advanced_personal_data(access_token, verifier)
  end
end
