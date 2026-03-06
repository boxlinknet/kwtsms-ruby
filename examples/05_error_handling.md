# Error Handling

Demonstrates comprehensive error handling with kwtsms.

## Error Response Structure

Every error response includes:
- `result`: always `"ERROR"`
- `code`: error code (e.g., `"ERR003"`, `"ERR_INVALID_INPUT"`, `"NETWORK"`)
- `description`: human-readable description
- `action`: developer-friendly guidance (for known error codes)

## Error Categories

**User-recoverable** (show helpful message to the user):
- ERR006/ERR025: invalid phone number
- ERR028: rate limited (wait 15 seconds)
- ERR031/ERR032: message content rejected

**System-level** (show generic message, log real error, alert admin):
- ERR003: wrong credentials
- ERR010/ERR011: no balance
- ERR024: IP not whitelisted
- NETWORK: connection issues

## Run

```bash
ruby 05_error_handling.rb
```
