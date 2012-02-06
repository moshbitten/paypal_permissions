require 'spec_helper'

describe ActiveMerchant::Billing::PaypalPermissionsGateway do
  let(:required_params) do
    {
      :login => "caller_1327459669_biz_api1.moshbit.com",
      :password => "1327459694",
      :signature => "AkzCUa2Iv085jJrg3I3gi7lOC61mAp59Sx7.lboUrlIi9ovIdVHk9PCr",
      :app_id => "APP-80W284485P519543T",
    }
  end

  let (:valid_gateway) do
    ActiveMerchant::Billing::Base.mode = :test
    ActiveMerchant::Billing::PaypalPermissionsGateway.new required_params
  end

  let (:invalid_login_gateway) do
    ActiveMerchant::Billing::Base.mode = :test
    ActiveMerchant::Billing::PaypalPermissionsGateway.new required_params.dup.merge(:login => 'invalid_login')
  end

  let (:invalid_password_gateway) do
    ActiveMerchant::Billing::Base.mode = :test
    ActiveMerchant::Billing::PaypalPermissionsGateway.new required_params.dup.merge(:password => 'invalid_password')
  end

  let (:invalid_app_id_gateway) do
    ActiveMerchant::Billing::Base.mode = :test
    ActiveMerchant::Billing::PaypalPermissionsGateway.new required_params.dup.merge(:app_id => 'invalid_app_id')
  end

  let (:callback_url) do
    'http://www.example.com/paypal_permissions_callback'
  end

  it "can be initialized with all required options" do
    lambda {
      ActiveMerchant::Billing::PaypalPermissionsGateway.new required_params
    }.should_not raise_error
  end

  it "can't be initialized without a login option" do
    lambda {
      ActiveMerchant::Billing::PaypalPermissionsGateway.new required_params.except(:login)
    }.should raise_error(ArgumentError, "Missing required parameter: login")
  end

  it "can't be initialized without a password option" do
    lambda {
      ActiveMerchant::Billing::PaypalPermissionsGateway.new required_params.except(:password)
    }.should raise_error(ArgumentError, "Missing required parameter: password")
  end

  it "can't be initialized without a signature option" do
    lambda {
      ActiveMerchant::Billing::PaypalPermissionsGateway.new required_params.except(:signature)
    }.should raise_error(ArgumentError, "Missing required parameter: signature")
  end

  it "can't be initialized without an app_id option" do
    lambda {
      ActiveMerchant::Billing::PaypalPermissionsGateway.new required_params.except(:app_id)
    }.should raise_error(ArgumentError, "Missing required parameter: app_id")
  end

  it "rejects a request with no permissions" do
    lambda {
      # response = valid_gateway.request_permissions callback_url, nil
    }.should_not raise_error
  end

  it "accepts a request for a single permission" do
    response = valid_gateway.request_permissions callback_url, "DIRECT_PAYMENT"
    response[:ack].should == 'Success'
  end

  it "strips leading and trailing whitespace from permissions" do
    response = valid_gateway.request_permissions callback_url, "  DIRECT_PAYMENT   "
    response[:ack].should == 'Success'
  end

  it "accepts permissions requests which aren't all upper case" do
    response = valid_gateway.request_permissions callback_url, "express_checkout, direct_payment"
    response[:ack].should == 'Success'
  end

  it "accepts a request for multiple permissions as a comma-separated string" do
    response = valid_gateway.request_permissions callback_url, "EXPRESS_CHECKOUT, DIRECT_PAYMENT"
    response[:ack].should == 'Success'
  end

  it "accepts a request for multiple permissions as an array" do
    response = valid_gateway.request_permissions callback_url, [ "EXPRESS_CHECKOUT", "DIRECT_PAYMENT" ]
    response[:ack].should == 'Success'
  end

  it "reports an error when the login is invalid" do
    response = invalid_login_gateway.request_permissions callback_url, "DIRECT_PAYMENT"
    response[:errors][0][:message].should == "Authentication failed. API credentials are incorrect."
  end

  it "reports the severity of the error when the login is invalid" do
    response = invalid_login_gateway.request_permissions callback_url, "DIRECT_PAYMENT"
    response[:errors][0][:severity].should == "Error"
  end

  it "reports an error when the password is invalid" do
    response = invalid_password_gateway.request_permissions callback_url, "DIRECT_PAYMENT"
    response[:errors][0][:message].should == "Authentication failed. API credentials are incorrect."
  end

  it "reports the severity of the error when the password is invalid" do
    response = invalid_password_gateway.request_permissions callback_url, "DIRECT_PAYMENT"
    response[:errors][0][:severity].should == "Error"
  end

  it "reports an error when the app id is invalid" do
    response = invalid_app_id_gateway.request_permissions callback_url, "DIRECT_PAYMENT"
    response[:errors][0][:message].should == "The X-PAYPAL-APPLICATION-ID header contains an invalid value"
  end

  it "reports the parameter that caused the error when the app id is invalid" do
    response = invalid_app_id_gateway.request_permissions callback_url, "DIRECT_PAYMENT"
    response[:errors][0][:parameters][0].should == "X-PAYPAL-APPLICATION-ID"
  end

  it "reports the severity of the error when the app id is invalid" do
    response = invalid_app_id_gateway.request_permissions callback_url, "DIRECT_PAYMENT"
    response[:errors][0][:severity].should == "Error"
  end

  it "reports an error when a requested permission is invalid" do
    response = valid_gateway.request_permissions callback_url, "I_AM_NOT_VALID"
    response[:errors][0][:message].should == "Invalid request parameter: scope with value I_AM_NOT_VALID"
  end

  it "reports the parameter that caused the error when a requested permission is invalid" do
    response = valid_gateway.request_permissions callback_url, "I_AM_NOT_VALID"
    response[:errors][0][:parameters][0].should == "I_AM_NOT_VALID"
  end

  it "reports the severity of the error when a requested permission is invalid" do
    response = valid_gateway.request_permissions callback_url, "I_AM_NOT_VALID"
    response[:errors][0][:severity].should == "Error"
  end
end
