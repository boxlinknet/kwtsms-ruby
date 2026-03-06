# Rails Endpoint

Demonstrates integrating kwtsms into a Ruby on Rails application.

## Setup

1. Add to your `Gemfile`:
   ```ruby
   gem "kwtsms"
   ```

2. Create an initializer at `config/initializers/kwtsms.rb`:
   ```ruby
   KWTSMS_CLIENT = KwtSMS::Client.from_env
   ```

3. Set environment variables (or use `.env` in development):
   ```ini
   KWTSMS_USERNAME=your_api_user
   KWTSMS_PASSWORD=your_api_pass
   KWTSMS_SENDER_ID=YOUR-SENDER
   KWTSMS_TEST_MODE=0
   ```

## Key Points

- Create the client once in an initializer, reuse across requests
- Never expose raw API errors to end users
- Map API errors to user-friendly messages
- Log real errors for admin review
- Use `before_action` for authentication/authorization
- Validate phone input locally before calling the API
