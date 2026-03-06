# frozen_string_literal: true

# In-memory OTP store for development and testing.
# For production, use RedisStore or a database-backed store.

module KwtSMS
  module OTP
    class MemoryStore
      def initialize
        @data = {}
        @mutex = Mutex.new
      end

      def get(phone)
        @mutex.synchronize { @data[phone] }
      end

      def set(phone, entry)
        @mutex.synchronize { @data[phone] = entry }
      end

      def delete(phone)
        @mutex.synchronize { @data.delete(phone) }
      end

      def increment_attempts(phone)
        @mutex.synchronize do
          @data[phone][:attempts] += 1 if @data[phone]
        end
      end

      def cleanup_expired
        now = Time.now.to_i
        @mutex.synchronize do
          @data.delete_if { |_, v| v[:expires_at] < now }
        end
      end
    end
  end
end
