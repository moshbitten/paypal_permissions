require 'spec_helper'

describe ActiveMerchant::Billing::PaypalPermissionsGateway do
  let(:required_params) do
    {
      :login => 'fred.login',
      :password => 'fred.password',
      :signature => 'fred.signature',
      :app_id => 'fred.app_id',
    }
  end

  it "requires a login option" do
    lambda {
      ActiveMerchant::Billing::PaypalPermissionsGateway.new required_params.except(:login)
    }.should raise_error(ArgumentError, "Missing required parameter: login")
  end

  it "requires a password option" do
    lambda {
      ActiveMerchant::Billing::PaypalPermissionsGateway.new required_params.except(:password)
    }.should raise_error(ArgumentError, "Missing required parameter: password")
  end

  it "requires a signature option" do
    lambda {
      ActiveMerchant::Billing::PaypalPermissionsGateway.new required_params.except(:signature)
    }.should raise_error(ArgumentError, "Missing required parameter: signature")
  end

  it "requires an app_id option" do
    lambda {
      ActiveMerchant::Billing::PaypalPermissionsGateway.new required_params.except(:app_id)
    }.should raise_error(ArgumentError, "Missing required parameter: app_id")
  end
end
