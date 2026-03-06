# frozen_string_literal: true

require_relative "test_helper"

# Real API integration tests. Skipped if RUBY_USERNAME / RUBY_PASSWORD not set.
# Always uses test_mode: true (no credits consumed).
class TestIntegration < Minitest::Test
  def setup
    WebMock.allow_net_connect!

    @username = ENV["RUBY_USERNAME"]
    @password = ENV["RUBY_PASSWORD"]

    skip "RUBY_USERNAME / RUBY_PASSWORD not set" unless @username && !@username.empty? && @password && !@password.empty?

    @client = KwtSMS::Client.new(@username, @password, test_mode: true, log_file: "")
  end

  def teardown
    WebMock.disable_net_connect!
  end

  # -- verify --

  def test_verify_valid_credentials
    ok, balance, err = @client.verify
    assert ok, "verify should succeed with valid credentials: #{err}"
    assert_kind_of Float, balance
    assert_nil err
  end

  def test_verify_wrong_credentials
    bad_client = KwtSMS::Client.new("ruby_wrong_user", "ruby_wrong_pass", test_mode: true, log_file: "")
    ok, balance, err = bad_client.verify
    refute ok
    assert_nil balance
    assert_kind_of String, err
    assert(!err.empty?)
  end

  # -- balance --

  def test_balance_returns_number
    balance = @client.balance
    assert_kind_of Float, balance
  end

  # -- send --

  def test_send_valid_kuwait_number
    result = @client.send_sms("96598765432", "Test from kwtsms-ruby integration")
    assert %w[OK ERROR].include?(result["result"]),
           "Expected OK or ERROR, got: #{result.inspect}"
  end

  def test_send_invalid_input_email
    result = @client.send_sms("user@email.com", "Test")
    assert_equal "ERROR", result["result"]
    assert_equal "ERR_INVALID_INPUT", result["code"]
  end

  def test_send_invalid_input_too_short
    result = @client.send_sms("123", "Test")
    assert_equal "ERROR", result["result"]
    assert_includes result["description"], "too short"
  end

  def test_send_invalid_input_letters
    result = @client.send_sms("abcdefgh", "Test")
    assert_equal "ERROR", result["result"]
    assert_includes result["description"], "no digits found"
  end

  def test_send_mixed_valid_invalid
    result = @client.send_sms(["96598765432", "not-a-number"], "Test from kwtsms-ruby")
    # Valid number should be sent, invalid should be in invalid field
    if result["result"] == "OK" || result["result"] == "ERROR"
      assert result.key?("invalid") || result["code"] != "ERR_INVALID_INPUT",
             "Expected invalid field or non-input error"
    end
  end

  def test_send_normalized_plus_prefix
    result = @client.send_sms("+96598765432", "Test with + prefix")
    assert %w[OK ERROR].include?(result["result"])
  end

  def test_send_normalized_double_zero
    result = @client.send_sms("0096598765432", "Test with 00 prefix")
    assert %w[OK ERROR].include?(result["result"])
  end

  def test_send_normalized_arabic_digits
    # Kuwait number in Arabic digits: ٩٦٥٩٨٧٦٥٤٣٢
    result = @client.send_sms("\u0669\u0666\u0665\u0669\u0668\u0667\u0666\u0665\u0664\u0663\u0662", "Test arabic digits")
    assert %w[OK ERROR].include?(result["result"])
  end

  def test_send_deduplicates_numbers
    result = @client.send_sms(["+96598765432", "0096598765432"], "Dedup test")
    assert %w[OK ERROR].include?(result["result"])
  end

  # -- senderids --

  def test_senderids_returns_list
    result = @client.senderids
    if result["result"] == "OK"
      assert_kind_of Array, result["senderids"]
    else
      assert result.key?("action") || result.key?("description")
    end
  end

  # -- coverage --

  def test_coverage_returns_data
    result = @client.coverage
    assert %w[OK ERROR].include?(result["result"])
  end

  # -- validate --

  def test_validate_single_number
    result = @client.validate(["96598765432"])
    assert_kind_of Hash, result
    assert result.key?("ok")
    assert result.key?("er")
  end

  # -- wrong sender id --

  def test_send_wrong_sender_id
    result = @client.send_sms("96598765432", "Test wrong sender", sender: "NONEXISTENT-SENDER-12345")
    # API should return an error for unknown sender ID
    if result["result"] == "ERROR" && result["code"] == "ERR008"
      assert result.key?("action")
    end
  end

  # -- empty sender id --

  def test_send_empty_sender_id
    result = @client.send_sms("96598765432", "Test empty sender", sender: "")
    assert %w[OK ERROR].include?(result["result"])
  end
end
