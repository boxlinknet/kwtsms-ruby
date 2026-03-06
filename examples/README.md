# Examples

| # | Example | Description |
|---|---------|-------------|
| 01 | [Basic Usage](01_basic_usage.rb) | Connect, verify, send SMS, validate numbers |
| 02 | [OTP Flow](02_otp_flow.rb) | Send OTP codes with proper formatting |
| 03 | [Bulk SMS](03_bulk_sms.rb) | Send to many recipients with auto-batching |
| 04 | [Rails Endpoint](04_rails_endpoint.rb) | Rails controller integration |
| 05 | [Error Handling](05_error_handling.rb) | Handle every error type properly |
| 06 | [OTP Production](06-otp-production/) | Production OTP: rate limiting, CAPTCHA, Redis, Rails, Sinatra |

## Running Examples

1. Install the gem:
   ```bash
   gem install kwtsms
   ```

2. Create a `.env` file:
   ```ini
   KWTSMS_USERNAME=ruby_username
   KWTSMS_PASSWORD=ruby_password
   KWTSMS_SENDER_ID=YOUR-SENDER
   KWTSMS_TEST_MODE=1
   ```

3. Run an example:
   ```bash
   ruby examples/01_basic_usage.rb
   ```
