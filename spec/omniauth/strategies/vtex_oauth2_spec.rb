# frozen_string_literal: true

def make_env(path = "/auth/test", props = {})
  {
    "REQUEST_METHOD" => "GET",
    "PATH_INFO" => path,
    "rack.session" => {},
    "rack.input" => StringIO.new("test=true")
  }.merge(props)
end

RSpec.describe OmniAuth::Strategies::VtexOauth2 do
  let(:request) { double("Request", params: {}, cookies: {}, env: {}) }
  let(:app) do
    ->(_env) { [404, {}, ["Hi from VTEX!"]] }
  end
  let!(:client_id) { "myaccount_xpto_8b539b66-2b2e-4218-8093-d61cff524703" }
  let!(:client_secret) { "3b9f217a-8d14-42b9-ba65-731bac7d40e8" }

  subject(:strategy) do
    OmniAuth::Strategies::VtexOauth2.new(app, client_id, client_secret, account: "some_account").tap do |strategy|
      allow(strategy).to receive(:request).and_return(request)
    end
  end

  before { OmniAuth.config.test_mode = true }
  after { OmniAuth.config.test_mode = false }

  describe "#client_options" do
    subject { strategy.client.options }

    it { is_expected.to include(authorization_url: "/_v/oauth2/auth") }
    it { is_expected.to include(token_url: "/_v/oauth2/token") }
  end

  describe "#uid" do
    subject { strategy.uid }

    let!(:access_token) { { "user_id" => "ebe71d93-4a77-4e51-a7f7-b2fd44b215d2" } }
    before { allow(strategy).to receive(:access_token).and_return access_token }

    it { is_expected.to eq("ebe71d93-4a77-4e51-a7f7-b2fd44b215d2") }
  end

  describe "#info" do
    subject { strategy.info }

    let!(:access_token) { { "unique_name" => "John Doe", "email" => "john.doe@example.com" } }
    before { allow(strategy).to receive(:access_token).and_return access_token }

    it { is_expected.to include(name: "John Doe") }
    it { is_expected.to include(email: "john.doe@example.com") }
  end
end
