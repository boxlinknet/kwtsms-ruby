# frozen_string_literal: true

# Basic usage example for kwtsms Ruby gem
#
# Setup:
#   gem install kwtsms
#
# Create a .env file:
#   KWTSMS_USERNAME=ruby_username
#   KWTSMS_PASSWORD=ruby_password
#   KWTSMS_SENDER_ID=YOUR-SENDER
#   KWTSMS_TEST_MODE=1

require "kwtsms"

# Create client from environment variables / .env file
sms = KwtSMS::Client.from_env

# Verify credentials and check balance
ok, balance, err = sms.verify
if ok
  puts "Connected! Balance: #{balance} credits"
else
  puts "Failed: #{err}"
  exit 1
end

# Send a single SMS
result = sms.send_sms("96598765432", "Hello from kwtsms-ruby!")
if result["result"] == "OK"
  puts "Sent! msg-id: #{result['msg-id']}"
  puts "Balance after: #{result['balance-after']}"
else
  puts "Error: #{result['description']}"
  puts "Action: #{result['action']}" if result["action"]
end

# Send to multiple numbers
result = sms.send_sms(
  ["96598765432", "96512345678"],
  "Bulk message test"
)
puts result.inspect

# Validate phone numbers
report = sms.validate(["96598765432", "invalid", "+96512345678"])
puts "Valid: #{report['ok']}"
puts "Errors: #{report['er']}"
puts "Rejected: #{report['rejected']}"

# Check delivery status
# msg_id = result["msg-id"]  # from a previous send
# delivery = sms.status(msg_id)
# puts delivery.inspect
