# Bulk SMS

Demonstrates sending SMS to many recipients with automatic batching.

## How Bulk Send Works

When you pass more than 200 numbers to `send_sms`, the library:

1. Splits numbers into batches of 200
2. Sends each batch with a 0.5s delay (stays within API rate limits)
3. On ERR013 (queue full), retries up to 3 times with 30s/60s/120s backoff
4. Returns an aggregated result: `OK`, `PARTIAL`, or `ERROR`

## Best Practices

- Check balance before bulk sends: estimate cost = recipients x pages per message
- Save all `msg-ids` for delivery status tracking
- Monitor `errors` array in the response for failed batches
- Use `balance-after` from the response instead of calling `balance` separately

## Run

```bash
ruby 03_bulk_sms.rb
```
