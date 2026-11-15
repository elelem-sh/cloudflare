# frozen_string_literal: true

require "elelem/openai"

require_relative "cloudflare/version"

Elelem.configure do |config|
  config.provider(:cloudflare) do |model: nil, **|
    # A variable that is set but empty counts as unset.
    env = ->(name) { ENV[name].to_s.strip.then { |v| v.empty? ? nil : v } }
    key = env.call("CLOUDFLARE_API_TOKEN")
    raise KeyError, "CLOUDFLARE_API_TOKEN is not set" if key.nil?

    model = env.call("CLOUDFLARE_MODEL") if model.to_s.strip.empty?
    raise KeyError, "CLOUDFLARE_MODEL is not set. Pass --model or set CLOUDFLARE_MODEL" if model.nil?

    base_url = env.call("CLOUDFLARE_BASE_URL") || begin
      account = env.call("CLOUDFLARE_ACCOUNT_ID")
      raise KeyError, "CLOUDFLARE_ACCOUNT_ID is not set. Set it or CLOUDFLARE_BASE_URL" if account.nil?

      "https://api.cloudflare.com/client/v4/accounts/#{account}/ai/v1"
    end

    Elelem::OpenAI::Provider.new(model:, api_key: key, base_url:)
  end
end
