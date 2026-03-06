# frozen_string_literal: true

require_relative "test_helper"
load File.expand_path("../exe/kwtsms", __dir__)

# CLI integration tests against real API.
# Skipped if RUBY_USERNAME / RUBY_PASSWORD not set.
# Always uses test_mode: true.
class TestCLIIntegration < Minitest::Test
  def setup
    WebMock.allow_net_connect!

    @original_env = ENV.to_h
    @username = ENV["RUBY_USERNAME"]
    @password = ENV["RUBY_PASSWORD"]

    skip "RUBY_USERNAME / RUBY_PASSWORD not set" unless @username && !@username.empty? && @password && !@password.empty?

    ENV["KWTSMS_USERNAME"] = @username
    ENV["KWTSMS_PASSWORD"] = @password
    ENV["KWTSMS_TEST_MODE"] = "1"
    ENV["KWTSMS_LOG_FILE"] = ""
  end

  def teardown
    ENV.replace(@original_env)
    WebMock.disable_net_connect!
  end

  # -- CLI verify --

  def test_cli_verify
    out, = capture_io { KwtSMS::CLI.run(["verify"]) }
    assert_includes out, "Credentials: OK"
    assert_match(/Balance: \d+/, out)
  end

  # -- CLI balance --

  def test_cli_balance
    out, = capture_io { KwtSMS::CLI.run(["balance"]) }
    assert_includes out, "Available:"
    assert_match(/\d+\.\d+ credits/, out)
  end

  # -- CLI senderid --

  def test_cli_senderid
    out, = capture_io { KwtSMS::CLI.run(["senderid"]) }
    # Either lists sender IDs or says none registered
    assert(out.include?("Sender IDs:") || out.include?("No sender IDs"),
           "Expected sender ID listing, got: #{out}")
  end

  # -- CLI single send --

  def test_cli_send_single_number
    credits_needed = 1
    balance_out, = capture_io { KwtSMS::CLI.run(["balance"]) }
    balance_before = balance_out[/Available: ([\d.]+)/, 1].to_f
    skip "Need at least #{credits_needed} credit (have #{balance_before})" if balance_before < credits_needed

    out, err = capture_io { KwtSMS::CLI.run(["send", "96598765432", "CLI single test"]) }
    assert_includes err, "WARNING: Test mode is ON"
    assert_includes out, "Message sent successfully"
    assert_match(/msg-id:/, out)
    assert_includes out, "Points charged: #{credits_needed}"
    balance_after = out[/Balance after: ([\d.]+)/, 1].to_f
    assert_in_delta balance_before - credits_needed, balance_after, 1.5,
      "CLI balance: #{balance_before} - #{credits_needed} should = #{balance_after}"
  end

  # -- CLI bulk send 250 numbers --

  def test_cli_bulk_send_250_numbers
    credits_needed = 250
    balance_out, = capture_io { KwtSMS::CLI.run(["balance"]) }
    balance_before = balance_out[/Available: ([\d.]+)/, 1].to_f
    skip "Need at least #{credits_needed} credits (have #{balance_before})" if balance_before < credits_needed

    # Generate 250 comma-separated numbers: 96599220000-96599220249
    numbers = (0...credits_needed).map { |i| format("9659922%04d", i) }
    numbers_csv = numbers.join(",")

    # Send via CLI — should produce 2 batches (200+50)
    out, err = capture_io { KwtSMS::CLI.run(["send", numbers_csv, "CLI bulk test 250"]) }

    assert_includes err, "WARNING: Test mode is ON"
    assert_includes out, "Message sent successfully"
    assert_includes out, "Batches: 2"
    assert_match(/msg-ids:/, out)
    assert_includes out, "Numbers: #{credits_needed}"
    assert_includes out, "Points charged: #{credits_needed}"
    balance_after = out[/Balance after: ([\d.]+)/, 1].to_f
    assert_in_delta balance_before - credits_needed, balance_after, 1.5,
      "CLI balance: #{balance_before} - #{credits_needed} should = #{balance_after}"
  end

  # -- CLI validate --

  def test_cli_validate
    out, = capture_io { KwtSMS::CLI.run(["validate", "96598765432", "invalid"]) }
    assert_includes out, "96598765432"
    assert_includes out, "Locally rejected"
  end
end
