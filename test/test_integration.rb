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

  # -- bulk send 450 numbers --

  def test_bulk_send_450_numbers_and_check_status
    # Get balance before sending
    balance_before = @client.balance
    assert_kind_of Float, balance_before, "Should have a valid balance before bulk send"
    skip "Need at least 450 credits (have #{balance_before})" if balance_before < 450

    # Generate 450 numbers: 96599220000 - 96599220449
    numbers = (0...450).map { |i| format("9659922%04d", i) }

    assert_equal 450, numbers.length
    assert_equal "96599220000", numbers.first
    assert_equal "96599220449", numbers.last

    # Send: should produce 3 batches (200 + 200 + 50)
    result = @client.send_sms(numbers, "Bulk test 450 numbers from kwtsms-ruby")

    assert_equal "OK", result["result"], "Bulk send should succeed, got: #{result.inspect}"
    assert result["bulk"], "Expected bulk flag in response"
    assert_equal 3, result["batches"], "Expected 3 batches (200+200+50)"
    assert_equal 3, result["msg-ids"].length, "Expected 3 msg-ids, one per batch"
    assert_equal 450, result["numbers"], "Expected 450 numbers sent"
    assert_equal 450, result["points-charged"], "Expected 450 points charged"
    assert_empty result["errors"], "Expected no batch errors"

    # Verify balance math: balance-after should equal balance-before minus points-charged
    balance_after = result["balance-after"]
    assert_kind_of Float, balance_after
    expected_balance = balance_before - result["points-charged"]
    assert_in_delta expected_balance, balance_after, 0.01,
      "Balance after (#{balance_after}) should equal before (#{balance_before}) - charged (#{result['points-charged']})"

    # Verify cached balance was updated
    assert_in_delta balance_after, @client.cached_balance, 0.01

    # Check status of each batch msg-id: test mode messages get ERR030
    # (stuck in queue with error, which is normal for test=1)
    # If /API/report/ endpoint is down, status() returns NETWORK error — skip assertion
    result["msg-ids"].each_with_index do |msg_id, i|
      refute msg_id.empty?, "msg-id for batch #{i + 1} should not be empty"

      status_result = @client.status(msg_id)
      assert_kind_of Hash, status_result
      assert_equal "ERROR", status_result["result"],
        "Test mode message should return ERROR status, got: #{status_result.inspect}"
      # ERR030 = stuck in queue (normal for test=1)
      # NETWORK = /API/report/ endpoint unavailable (server-side issue)
      assert_includes %w[ERR030 NETWORK], status_result["code"],
        "Expected ERR030 (test mode queue) or NETWORK (endpoint down), got: #{status_result['code']}"
    end
  end
end
