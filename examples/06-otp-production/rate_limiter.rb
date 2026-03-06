# frozen_string_literal: true

# Rate limiter for SMS sends.
#
# Limits:
# - Per phone number: max 5/hour
# - Per IP address: max 20/hour
# - Per user (if authenticated): max 5/hour
#
# Uses in-memory storage. For production, use Redis for shared state across processes.

module KwtSMS
  module OTP
    class RateLimiter
      def initialize(phone_limit: 5, ip_limit: 20, user_limit: 5, window_seconds: 3600)
        @phone_limit = phone_limit
        @ip_limit = ip_limit
        @user_limit = user_limit
        @window = window_seconds
        @counters = {}
        @mutex = Mutex.new
      end

      # Check if a request is allowed. Returns [allowed, error_message].
      def check(phone:, ip: nil, user_id: nil)
        now = Time.now.to_i

        # Check phone limit
        phone_key = "phone:#{phone}"
        unless under_limit?(phone_key, @phone_limit, now)
          return [false, "Too many requests to this number. Please try again later."]
        end

        # Check IP limit
        if ip
          ip_key = "ip:#{ip}"
          unless under_limit?(ip_key, @ip_limit, now)
            return [false, "Too many requests. Please try again later."]
          end
        end

        # Check user limit
        if user_id
          user_key = "user:#{user_id}"
          unless under_limit?(user_key, @user_limit, now)
            return [false, "Too many requests. Please try again later."]
          end
        end

        # Record the request
        record(phone_key, now)
        record("ip:#{ip}", now) if ip
        record("user:#{user_id}", now) if user_id

        [true, nil]
      end

      private

      def under_limit?(key, limit, now)
        @mutex.synchronize do
          entries = @counters[key] || []
          # Clean old entries outside window
          entries = entries.select { |t| t > now - @window }
          @counters[key] = entries
          entries.length < limit
        end
      end

      def record(key, now)
        @mutex.synchronize do
          @counters[key] ||= []
          @counters[key] << now
        end
      end
    end
  end
end
