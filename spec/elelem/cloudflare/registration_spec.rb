# frozen_string_literal: true

RSpec.describe "the cloudflare provider" do
  vars = %w[CLOUDFLARE_API_TOKEN CLOUDFLARE_ACCOUNT_ID CLOUDFLARE_BASE_URL CLOUDFLARE_MODEL]

  around do |example|
    saved = ENV.to_h.slice(*vars)
    example.run
  ensure
    vars.each { |k| ENV.delete(k) }
    ENV.update(saved)
  end

  before do
    ENV["CLOUDFLARE_API_TOKEN"] = "test-token"
    ENV["CLOUDFLARE_ACCOUNT_ID"] = "test-account"
    ENV["CLOUDFLARE_MODEL"] = "env-model"
    ENV.delete("CLOUDFLARE_BASE_URL")
  end

  def build(**) = Elelem::Config.build_provider("cloudflare", **)
  def uri(**) = build(**).instance_variable_get(:@uri).to_s
  def model(**) = build(**).instance_variable_get(:@model)

  let(:default_uri) { "https://api.cloudflare.com/client/v4/accounts/test-account/ai/v1/chat/completions" }

  it "registers provider cloudflare" do
    expect(Elelem::Config.names).to include("cloudflare")
    expect(build).to be_a(Elelem::OpenAI::Provider)
  end

  it "talks to the account's Workers AI endpoint by default" do
    expect(uri).to eq(default_uri)
  end

  it "sends CLOUDFLARE_API_TOKEN" do
    expect(build.instance_variable_get(:@api_key)).to eq("test-token")
  end

  it "names CLOUDFLARE_API_TOKEN when the token is missing or empty" do
    ENV.delete("CLOUDFLARE_API_TOKEN")
    expect { build }.to raise_error(KeyError, /CLOUDFLARE_API_TOKEN/)

    ENV["CLOUDFLARE_API_TOKEN"] = " "
    expect { build }.to raise_error(KeyError, /CLOUDFLARE_API_TOKEN/)
  end

  it "names CLOUDFLARE_ACCOUNT_ID when it is missing or empty" do
    ENV.delete("CLOUDFLARE_ACCOUNT_ID")
    expect { build }.to raise_error(KeyError, /CLOUDFLARE_ACCOUNT_ID/)

    ENV["CLOUDFLARE_ACCOUNT_ID"] = ""
    expect { build }.to raise_error(KeyError, /CLOUDFLARE_ACCOUNT_ID/)
  end

  it "needs no CLOUDFLARE_ACCOUNT_ID when CLOUDFLARE_BASE_URL is set" do
    ENV.delete("CLOUDFLARE_ACCOUNT_ID")
    ENV["CLOUDFLARE_BASE_URL"] = "http://127.0.0.1:8080/v1"
    expect(uri).to eq("http://127.0.0.1:8080/v1/chat/completions")
  end

  it "names CLOUDFLARE_MODEL when no model is set, and treats an empty one as unset" do
    ENV.delete("CLOUDFLARE_MODEL")
    expect { build }.to raise_error(KeyError, /CLOUDFLARE_MODEL/)

    ENV["CLOUDFLARE_MODEL"] = ""
    expect { build }.to raise_error(KeyError, /CLOUDFLARE_MODEL/)
  end

  it "takes the model from CLOUDFLARE_MODEL" do
    expect(model).to eq("env-model")
  end

  it "prefers --model over CLOUDFLARE_MODEL" do
    expect(model(model: "flag-model")).to eq("flag-model")
  end

  it "uses CLOUDFLARE_BASE_URL, with or without a trailing slash, and treats an empty one as unset" do
    ENV["CLOUDFLARE_BASE_URL"] = "http://127.0.0.1:8080/v1/"
    expect(uri).to eq("http://127.0.0.1:8080/v1/chat/completions")

    ENV["CLOUDFLARE_BASE_URL"] = "http://127.0.0.1:8080/v1"
    expect(uri).to eq("http://127.0.0.1:8080/v1/chat/completions")

    ENV["CLOUDFLARE_BASE_URL"] = ""
    expect(uri).to eq(default_uri)
  end
end
