# frozen_string_literal: true

# CAPTCHA verification for OTP requests.
# Supports Cloudflare Turnstile (recommended, free) and hCaptcha.
#
# Every form that triggers an SMS send MUST have CAPTCHA protection.
# Without it, bots can drain your entire SMS balance in minutes.

require "net/http"
require "json"
require "uri"

module KwtSMS
  module OTP
    class CaptchaVerifier
      # Cloudflare Turnstile (recommended, free)
      # Get keys at: https://dash.cloudflare.com/turnstile
      def self.verify_turnstile(token, secret_key, remote_ip: nil)
        uri = URI("https://challenges.cloudflare.com/turnstile/v0/siteverify")
        payload = { secret: secret_key, response: token }
        payload[:remoteip] = remote_ip if remote_ip

        response = Net::HTTP.post_form(uri, payload)
        data = JSON.parse(response.body)
        data["success"] == true
      rescue StandardError
        false
      end

      # hCaptcha (GDPR-safe alternative)
      # Get keys at: https://www.hcaptcha.com/
      def self.verify_hcaptcha(token, secret_key, remote_ip: nil)
        uri = URI("https://hcaptcha.com/siteverify")
        payload = { secret: secret_key, response: token }
        payload[:remoteip] = remote_ip if remote_ip

        response = Net::HTTP.post_form(uri, payload)
        data = JSON.parse(response.body)
        data["success"] == true
      rescue StandardError
        false
      end
    end
  end
end
