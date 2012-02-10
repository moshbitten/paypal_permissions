require 'active_support/core_ext/hash/except'
require 'active_merchant/billing/gateways/paypal_permissions'
require 'ammeter/init'

class Rails::Application; end
module Agentfriday
  class Application < Rails::Application; end
end
module Rails
  def self.application
    Agentfriday::Application.new
  end
end
