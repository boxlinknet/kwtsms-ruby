# frozen_string_literal: true

# Production OTP service for kwtsms
#
# Features:
# - Secure random code generation
# - Configurable expiry and resend cooldown
# - Max attempts per code
# - New code on every resend (invalidates previous)
# - Works with any store backend (memory, Redis, database)

require "kwtsms"
require "securerandom"

module KwtSMS
  module OTP
    class Service
      DEFAULT_OPTIONS = {
        code_length: 6,
        expiry_seconds: 300,        # 5 minutes
        resend_cooldown: 240,       # 4 minutes (KNET standard)
        max_attempts: 5,
        app_name: "MyApp",
        sender_id: nil               # uses client default
      }.freeze

      def initialize(sms_client, store, options = {})
        @sms = sms_client
        @store = store
        @options = DEFAULT_OPTIONS.merge(options)
      end

      # Request an OTP for a phone number.
      # Returns: { ok: true, message: "..." } or { ok: false, error: "..." }
      def request(phone, ip: nil, user_id: nil)
        valid, error, normalized = KwtSMS.validate_phone_input(phone)
        return { ok: false, error: error } unless valid

        # Check resend cooldown
        existing = @store.get(normalized)
        if existing && existing[:created_at]
          elapsed = Time.now.to_i - existing[:created_at]
          remaining = @options[:resend_cooldown] - elapsed
          if remaining > 0
            return { ok: false, error: "Please wait #{remaining} seconds before requesting a new code." }
          end
        end

        # Generate new code (invalidates any previous code)
        code = generate_code
        @store.set(normalized, {
          code: code,
          attempts: 0,
          created_at: Time.now.to_i,
          expires_at: Time.now.to_i + @options[:expiry_seconds]
        })

        # Send OTP
        message = "Your OTP for #{@options[:app_name]} is: #{code}. Valid for #{@options[:expiry_seconds] / 60} minutes."
        result = @sms.send_sms(normalized, message, sender: @options[:sender_id])

        if result["result"] == "OK"
          { ok: true, message: "OTP sent successfully.", msg_id: result["msg-id"] }
        else
          @store.delete(normalized)
          { ok: false, error: "Failed to send OTP. Please try again." }
        end
      end

      # Verify an OTP code.
      # Returns: { ok: true } or { ok: false, error: "..." }
      def verify(phone, code)
        _, _, normalized = KwtSMS.validate_phone_input(phone)
        return { ok: false, error: "Invalid phone number." } if normalized.empty?

        entry = @store.get(normalized)
        return { ok: false, error: "No OTP requested for this number." } unless entry

        if Time.now.to_i > entry[:expires_at]
          @store.delete(normalized)
          return { ok: false, error: "OTP has expired. Request a new one." }
        end

        if entry[:attempts] >= @options[:max_attempts]
          @store.delete(normalized)
          return { ok: false, error: "Too many attempts. Request a new OTP." }
        end

        @store.increment_attempts(normalized)

        if entry[:code] == code.to_s.strip
          @store.delete(normalized)
          { ok: true }
        else
          remaining = @options[:max_attempts] - entry[:attempts] - 1
          { ok: false, error: "Invalid OTP. #{remaining} attempt#{'s' if remaining != 1} remaining." }
        end
      end

      private

      def generate_code
        min = 10**(@options[:code_length] - 1)
        max = (10**@options[:code_length]) - 1
        (SecureRandom.random_number(max - min) + min).to_s
      end
    end
  end
end
