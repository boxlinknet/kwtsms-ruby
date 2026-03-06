# Production OTP Implementation

A complete, production-ready OTP (One-Time Password) system for Ruby applications.

This example includes rate limiting, CAPTCHA verification, secure code generation, and framework integration patterns.

## Files

| File | Purpose |
|------|---------|
| `otp_service.rb` | Core OTP logic: generate, verify, resend, cleanup |
| `memory_store.rb` | In-memory OTP store (development/testing) |
| `redis_store.rb` | Redis-backed OTP store (production) |
| `captcha_verifier.rb` | CAPTCHA verification (Cloudflare Turnstile, hCaptcha) |
| `rate_limiter.rb` | Rate limiting per phone, IP, and user |
| `rails_controller.rb` | Rails controller integration |
| `sinatra_app.rb` | Sinatra integration |

## Security Checklist

Before going live:
- [ ] Bot protection enabled (CAPTCHA for web)
- [ ] Rate limit per phone number (max 3-5/hour)
- [ ] Rate limit per IP address (max 10-20/hour)
- [ ] Rate limit per user/session if authenticated
- [ ] Monitoring/alerting on abuse patterns
- [ ] Admin notification on low balance
- [ ] Test mode OFF (`KWTSMS_TEST_MODE=0`)
- [ ] Private Sender ID registered (not KWT-SMS)
- [ ] Transactional Sender ID for OTP (not promotional)

## OTP Rules

1. **Expiry:** 5 minutes
2. **Resend cooldown:** 4 minutes (KNET standard)
3. **Max attempts:** 5 per code
4. **New code on resend:** invalidates all previous codes
5. **Transactional Sender ID required:** promotional IDs are filtered by DND
