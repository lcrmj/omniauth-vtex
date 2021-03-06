# frozen_string_literal: true

require "omniauth-oauth2"
require "json"
require "base64"

module OmniAuth
  module Strategies
    # Strategy implementation for VTEX OAuth2
    class VtexOauth2 < OmniAuth::Strategies::OAuth2
      option :name, "vtex_oauth2"
      option :account
      option :client_options, authorize_url: "/_v/oauth2/auth",
                              token_url: "/_v/oauth2/token"

      option :setup, (lambda do |env|
        strategy = env["omniauth.strategy"]
        account = strategy.options[:account]

        env["omniauth.strategy"].options[:client_options]["site"] = "https://#{account}.myvtex.com"
      end)

      uid { raw_info["user_id"] }

      info do
        {
          name: raw_info["unique_name"],
          email: raw_info["email"]
        }
      end

      def callback_url
        full_host + script_name + callback_path
      end      

      def raw_info
        #TODO: Add token validation(requires VTEX signing key)
        payload = JWT.decode(access_token.token, false, nil).first
      end
    end
  end
end
