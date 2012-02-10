require 'spec_helper'

# Generators are not automatically loaded by Rails
require 'generators/paypal_permissions/install_generator'

describe PaypalPermissions::Generators::InstallGenerator do
  snippet =<<-SNIPPET
Agentfriday::Application.configure do
end
  SNIPPET

  tmpdir = File.expand_path("../../../../tmp", __FILE__)
  destination tmpdir
  before { prepare_destination }

  describe 'no arguments' do
    before {
      `mkdir -p "#{tmpdir}/config/environments"`
      ["development", "test", "production"].each do |env|
        File::open("#{tmpdir}/config/environments/#{env}.rb", "w") do |f|
          f << snippet
        end
      end
      run_generator
    }

    describe 'config/environments/development.rb' do
      subject { file('config/environments/development.rb') }
      it { should exist }
      it { should contain "TODO: your PayPal" }
    end

    describe 'config/environments/test.rb' do
      subject { file('config/environments/test.rb') }
      it { should exist }
      it { should contain "TODO: your PayPal" }
    end

    describe 'config/environments/production.rb' do
      subject { file('config/environments/development.rb') }
      it { should exist }
      it { should contain "TODO: your PayPal" }
    end
  end
end
