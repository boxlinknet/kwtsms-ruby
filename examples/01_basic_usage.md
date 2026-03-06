# Basic Usage

Demonstrates core kwtsms functionality: connecting, checking balance, sending SMS, validating numbers.

## Prerequisites

```bash
gem install kwtsms
```

Create a `.env` file with your credentials:

```ini
KWTSMS_USERNAME=your_api_user
KWTSMS_PASSWORD=your_api_pass
KWTSMS_SENDER_ID=YOUR-SENDER
KWTSMS_TEST_MODE=1
```

## Run

```bash
ruby 01_basic_usage.rb
```

## Key Points

- `KwtSMS::Client.from_env` loads credentials from environment variables, falling back to `.env`
- `verify` tests credentials and returns `[ok, balance, error]`
- `send_sms` normalizes phone numbers and cleans messages automatically
- `validate` checks numbers locally first, then via the API
- Always save `msg-id` from successful sends for delivery status checks
- Never call `balance` after `send_sms`: the send response includes `balance-after`
