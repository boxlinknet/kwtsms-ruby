# frozen_string_literal: true

require_relative "test_helper"
load File.expand_path("../exe/kwtsms", __dir__)

class TestCLIVersion < Minitest::Test
  def test_version_output
    out, = capture_io { KwtSMS::CLI.run(["version"]) }
    assert_includes out, KwtSMS::VERSION
  end

  def test_version_flag
    out, = capture_io { KwtSMS::CLI.run(["--version"]) }
    assert_includes out, KwtSMS::VERSION
  end

  def test_version_short_flag
    out, = capture_io { KwtSMS::CLI.run(["-v"]) }
    assert_includes out, KwtSMS::VERSION
  end
end

class TestCLIHelp < Minitest::Test
  def test_help_output
    out, = capture_io { KwtSMS::CLI.run(["help"]) }
    assert_includes out, "kwtsms"
    assert_includes out, "setup"
    assert_includes out, "verify"
    assert_includes out, "send"
    assert_includes out, "validate"
  end

  def test_help_flag
    out, = capture_io { KwtSMS::CLI.run(["--help"]) }
    assert_includes out, "kwtsms"
  end

  def test_nil_command_shows_help
    out, = capture_io { KwtSMS::CLI.run([]) }
    assert_includes out, "kwtsms"
  end
end

class TestCLIUnknownCommand < Minitest::Test
  def test_unknown_command_exits_with_error
    assert_raises(SystemExit) do
      capture_io { KwtSMS::CLI.run(["nonexistent"]) }
    end
  end
end

class TestCLIVerify < Minitest::Test
  def setup
    @original_env = ENV.to_h
    ENV["KWTSMS_USERNAME"] = "ruby_username"
    ENV["KWTSMS_PASSWORD"] = "ruby_password"
    ENV["KWTSMS_LOG_FILE"] = ""
  end

  def teardown
    ENV.replace(@original_env)
  end

  def test_verify_success
    stub_request(:post, "https://www.kwtsms.com/API/balance/")
      .to_return(
        status: 200,
        body: { "result" => "OK", "available" => "150.5", "purchased" => "200" }.to_json,
        headers: { "Content-Type" => "application/json" }
      )

    out, = capture_io { KwtSMS::CLI.run(["verify"]) }
    assert_includes out, "Credentials: OK"
    assert_includes out, "150.5"
  end

  def test_verify_failure_exits
    stub_request(:post, "https://www.kwtsms.com/API/balance/")
      .to_return(
        status: 403,
        body: { "result" => "ERROR", "code" => "ERR003", "description" => "Auth error" }.to_json,
        headers: { "Content-Type" => "application/json" }
      )

    assert_raises(SystemExit) do
      capture_io { KwtSMS::CLI.run(["verify"]) }
    end
  end
end

class TestCLIBalance < Minitest::Test
  def setup
    @original_env = ENV.to_h
    ENV["KWTSMS_USERNAME"] = "ruby_username"
    ENV["KWTSMS_PASSWORD"] = "ruby_password"
    ENV["KWTSMS_LOG_FILE"] = ""
  end

  def teardown
    ENV.replace(@original_env)
  end

  def test_balance_output
    stub_request(:post, "https://www.kwtsms.com/API/balance/")
      .to_return(
        status: 200,
        body: { "result" => "OK", "available" => "42.0", "purchased" => "100" }.to_json,
        headers: { "Content-Type" => "application/json" }
      )

    out, = capture_io { KwtSMS::CLI.run(["balance"]) }
    assert_includes out, "Available: 42.0"
    assert_includes out, "Purchased: 100.0"
  end
end

class TestCLISenderids < Minitest::Test
  def setup
    @original_env = ENV.to_h
    ENV["KWTSMS_USERNAME"] = "ruby_username"
    ENV["KWTSMS_PASSWORD"] = "ruby_password"
    ENV["KWTSMS_LOG_FILE"] = ""
  end

  def teardown
    ENV.replace(@original_env)
  end

  def test_senderids_output
    stub_request(:post, "https://www.kwtsms.com/API/senderid/")
      .to_return(
        status: 200,
        body: { "result" => "OK", "senderid" => ["KWT-SMS", "MY-APP"] }.to_json,
        headers: { "Content-Type" => "application/json" }
      )

    out, = capture_io { KwtSMS::CLI.run(["senderid"]) }
    assert_includes out, "Sender IDs:"
    assert_includes out, "KWT-SMS"
    assert_includes out, "MY-APP"
  end

  def test_senderids_empty
    stub_request(:post, "https://www.kwtsms.com/API/senderid/")
      .to_return(
        status: 200,
        body: { "result" => "OK", "senderid" => [] }.to_json,
        headers: { "Content-Type" => "application/json" }
      )

    out, = capture_io { KwtSMS::CLI.run(["senderid"]) }
    assert_includes out, "No sender IDs registered"
  end

  def test_senderids_error_exits
    stub_request(:post, "https://www.kwtsms.com/API/senderid/")
      .to_return(
        status: 403,
        body: { "result" => "ERROR", "code" => "ERR003", "description" => "Auth" }.to_json,
        headers: { "Content-Type" => "application/json" }
      )

    assert_raises(SystemExit) do
      capture_io { KwtSMS::CLI.run(["senderid"]) }
    end
  end
end

class TestCLICoverage < Minitest::Test
  def setup
    @original_env = ENV.to_h
    ENV["KWTSMS_USERNAME"] = "ruby_username"
    ENV["KWTSMS_PASSWORD"] = "ruby_password"
    ENV["KWTSMS_LOG_FILE"] = ""
  end

  def teardown
    ENV.replace(@original_env)
  end

  def test_coverage_output
    stub_request(:post, "https://www.kwtsms.com/API/coverage/")
      .to_return(
        status: 200,
        body: { "result" => "OK", "prefixes" => ["965", "966"] }.to_json,
        headers: { "Content-Type" => "application/json" }
      )

    out, = capture_io { KwtSMS::CLI.run(["coverage"]) }
    assert_includes out, "Active coverage"
    assert_includes out, "965"
  end
end

class TestCLISend < Minitest::Test
  def setup
    @original_env = ENV.to_h
    ENV["KWTSMS_USERNAME"] = "ruby_username"
    ENV["KWTSMS_PASSWORD"] = "ruby_password"
    ENV["KWTSMS_TEST_MODE"] = "1"
    ENV["KWTSMS_LOG_FILE"] = ""
  end

  def teardown
    ENV.replace(@original_env)
  end

  def test_send_success
    stub_request(:post, "https://www.kwtsms.com/API/send/")
      .to_return(
        status: 200,
        body: { "result" => "OK", "msg-id" => "555", "numbers" => 1,
                "points-charged" => 1, "balance-after" => 99 }.to_json,
        headers: { "Content-Type" => "application/json" }
      )

    out, err = capture_io { KwtSMS::CLI.run(["send", "96598765432", "Hello"]) }
    assert_includes out, "Message sent successfully"
    assert_includes out, "555"
    assert_includes err, "WARNING: Test mode is ON"
  end

  def test_send_missing_args_exits
    assert_raises(SystemExit) do
      capture_io { KwtSMS::CLI.run(["send", "96598765432"]) }
    end
  end

  def test_send_no_args_exits
    assert_raises(SystemExit) do
      capture_io { KwtSMS::CLI.run(["send"]) }
    end
  end

  def test_send_error_exits
    stub_request(:post, "https://www.kwtsms.com/API/send/")
      .to_return(
        status: 200,
        body: { "result" => "ERROR", "code" => "ERR010", "description" => "Zero balance" }.to_json,
        headers: { "Content-Type" => "application/json" }
      )

    assert_raises(SystemExit) do
      capture_io { KwtSMS::CLI.run(["send", "96598765432", "Hello"]) }
    end
  end

  def test_send_with_sender_override
    stub_request(:post, "https://www.kwtsms.com/API/send/")
      .with { |req| JSON.parse(req.body)["sender"] == "CUSTOM" }
      .to_return(
        status: 200,
        body: { "result" => "OK", "msg-id" => "777", "numbers" => 1,
                "points-charged" => 1, "balance-after" => 98 }.to_json,
        headers: { "Content-Type" => "application/json" }
      )

    out, = capture_io { KwtSMS::CLI.run(["send", "96598765432", "Hello", "--sender", "CUSTOM"]) }
    assert_includes out, "Message sent successfully"
  end

  def test_send_comma_separated_numbers
    stub_request(:post, "https://www.kwtsms.com/API/send/")
      .with { |req| JSON.parse(req.body)["mobile"] == "96598765432,96512345678" }
      .to_return(
        status: 200,
        body: { "result" => "OK", "msg-id" => "888", "numbers" => 2,
                "points-charged" => 2, "balance-after" => 97 }.to_json,
        headers: { "Content-Type" => "application/json" }
      )

    out, = capture_io { KwtSMS::CLI.run(["send", "96598765432,96512345678", "Bulk"]) }
    assert_includes out, "Message sent successfully"
    assert_includes out, "Numbers: 2"
  end
end

class TestCLIValidate < Minitest::Test
  def setup
    @original_env = ENV.to_h
    ENV["KWTSMS_USERNAME"] = "ruby_username"
    ENV["KWTSMS_PASSWORD"] = "ruby_password"
    ENV["KWTSMS_LOG_FILE"] = ""
  end

  def teardown
    ENV.replace(@original_env)
  end

  def test_validate_success
    stub_request(:post, "https://www.kwtsms.com/API/validate/")
      .to_return(
        status: 200,
        body: {
          "result" => "OK",
          "mobile" => { "OK" => ["96598765432"], "ER" => [], "NR" => [] }
        }.to_json,
        headers: { "Content-Type" => "application/json" }
      )

    out, = capture_io { KwtSMS::CLI.run(["validate", "96598765432"]) }
    assert_includes out, "Valid (OK)"
    assert_includes out, "96598765432"
  end

  def test_validate_with_invalid_number
    out, = capture_io { KwtSMS::CLI.run(["validate", "abc"]) }
    assert_includes out, "Locally rejected"
    assert_includes out, "no digits found"
  end

  def test_validate_no_args_exits
    assert_raises(SystemExit) do
      capture_io { KwtSMS::CLI.run(["validate"]) }
    end
  end
end
