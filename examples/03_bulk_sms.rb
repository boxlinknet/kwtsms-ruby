# frozen_string_literal: true

# Bulk SMS example: sending to many recipients
#
# kwtsms automatically handles batching for >200 numbers:
# - Splits into batches of 200
# - 0.5s delay between batches
# - ERR013 (queue full) retry with 30s/60s/120s backoff

require "kwtsms"

sms = KwtSMS::Client.from_env

# Simulate a list of recipients
recipients = (1..500).map { |i| "9651000#{i.to_s.rjust(4, '0')}" }

# Check balance before bulk send
ok, balance, err = sms.verify
unless ok
  puts "Cannot verify: #{err}"
  exit 1
end

estimated_cost = recipients.length
if balance && balance < estimated_cost
  puts "Warning: balance (#{balance}) may be insufficient for #{recipients.length} messages"
end

# Send bulk SMS (auto-batched)
result = sms.send_sms(recipients, "Important announcement from MyApp")

case result["result"]
when "OK"
  puts "All #{result['batches']} batches sent successfully"
  puts "Total numbers: #{result['numbers']}"
  puts "Points charged: #{result['points-charged']}"
  puts "Balance after: #{result['balance-after']}"
  puts "Message IDs: #{result['msg-ids'].inspect}"
when "PARTIAL"
  puts "Partial success: #{result['msg-ids'].length}/#{result['batches']} batches"
  puts "Errors: #{result['errors'].inspect}"
when "ERROR"
  puts "All batches failed"
  puts "Errors: #{result['errors'].inspect}"
end
