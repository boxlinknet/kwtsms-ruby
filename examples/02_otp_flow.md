# OTP Flow

Demonstrates sending OTP (One-Time Password) codes via kwtSMS.

## Important OTP Rules

1. **Always include app/company name** in the message: telecom compliance requirement
2. **OTP expiry:** 3-5 minutes is standard
3. **Resend timer:** minimum 3-4 minutes before allowing resend (KNET standard: 4 minutes)
4. **New code on resend:** always generate a fresh code and invalidate previous codes
5. **Use Transactional Sender ID:** promotional sender IDs are filtered by DND on some carriers
6. **One number per request:** never batch OTP sends (ERR028 rate limit rejects entire batch)

## Run

```bash
ruby 02_otp_flow.rb
```
