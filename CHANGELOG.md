# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2026-03-06

### Added

- Initial release of the kwtsms Ruby gem
- `KwtSMS::Client` class with full API coverage:
  - `verify` : test credentials and check balance
  - `balance` : get current balance
  - `send_sms` : send SMS to one or more numbers
  - `send_with_retry` : send with automatic ERR028 retry
  - `senderids` : list registered sender IDs
  - `coverage` : list active country prefixes
  - `validate` : validate phone numbers
- `KwtSMS::Client.from_env` factory method for loading credentials from environment variables or `.env` file
- Utility functions:
  - `KwtSMS.normalize_phone` : normalize phone numbers (Arabic digits, strip non-digits, strip leading zeros)
  - `KwtSMS.validate_phone_input` : validate phone input with detailed error messages
  - `KwtSMS.clean_message` : clean SMS text (strip emojis, HTML, hidden chars, convert Arabic digits)
  - `KwtSMS.enrich_error` : add developer-friendly action messages to API errors
- `KwtSMS::API_ERRORS` constant with all kwtSMS error codes mapped to action messages
- Bulk send support: auto-batching for >200 numbers with ERR013 retry and backoff
- Phone number deduplication before sending
- JSONL logging with password masking
- CLI tool (`kwtsms`) with setup, verify, balance, senderid, coverage, send, and validate commands
- Zero external runtime dependencies (uses Ruby stdlib only)
- Comprehensive test suite: unit tests, mocked API tests, and real integration tests
- Examples: basic usage, OTP flow, bulk SMS, Rails endpoint, error handling, production OTP

[0.1.0]: https://github.com/boxlinknet/kwtsms-ruby/releases/tag/v0.1.0
