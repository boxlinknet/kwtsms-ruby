# frozen_string_literal: true

# Redis-backed OTP store for production.
# Requires the `redis` gem: gem install redis
#
# Usage:
#   require "redis"
#   redis = Redis.new(url: ENV["REDIS_URL"])
#   store = KwtSMS::OTP::RedisStore.new(redis)

require "json"

module KwtSMS
  module OTP
    class RedisStore
      PREFIX = "kwtsms:otp:"

      def initialize(redis, ttl: 600)
        @redis = redis
        @ttl = ttl
      end

      def get(phone)
        raw = @redis.get("#{PREFIX}#{phone}")
        return nil unless raw

        data = JSON.parse(raw)
        {
          code: data["code"],
          attempts: data["attempts"],
          created_at: data["created_at"],
          expires_at: data["expires_at"]
        }
      end

      def set(phone, entry)
        @redis.setex(
          "#{PREFIX}#{phone}",
          @ttl,
          JSON.generate(entry)
        )
      end

      def delete(phone)
        @redis.del("#{PREFIX}#{phone}")
      end

      def increment_attempts(phone)
        raw = @redis.get("#{PREFIX}#{phone}")
        return unless raw

        data = JSON.parse(raw)
        data["attempts"] += 1
        ttl = @redis.ttl("#{PREFIX}#{phone}")
        @redis.setex("#{PREFIX}#{phone}", [ttl, 1].max, JSON.generate(data))
      end
    end
  end
end
