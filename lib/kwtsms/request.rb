# frozen_string_literal: true

require "net/http"
require "uri"
require "json"
require "time"

module KwtSMS
  BASE_URL = "https://www.kwtsms.com/API/"

  # kwtSMS server runs at GMT+3 (Asia/Kuwait).
  # unix-timestamp values in API responses are server time, not UTC.
  SERVER_TIMEZONE = "Asia/Kuwait (GMT+3)"

  # POST to a kwtSMS REST/JSON API endpoint.
  #
  # Always sets Content-Type and Accept: application/json.
  # Strips password from log entry.
  # Returns parsed JSON hash.
  # Raises RuntimeError on network / HTTP / parse failure.
  def self.api_request(endpoint, payload, log_file = "")
    url = URI.parse("#{BASE_URL}#{endpoint}/")

    safe_payload = payload.transform_keys(&:to_s).each_with_object({}) do |(k, v), h|
      h[k] = k == "password" ? "***" : v
    end

    log_entry = {
      "ts" => Time.now.utc.iso8601,
      "endpoint" => endpoint,
      "request" => safe_payload,
      "response" => nil,
      "ok" => false,
      "error" => nil
    }

    begin
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      http.open_timeout = 15
      http.read_timeout = 15

      request = Net::HTTP::Post.new(url.path)
      request["Content-Type"] = "application/json"
      request["Accept"] = "application/json"
      request.body = JSON.generate(payload)

      response = http.request(request)
      body = response.body.to_s

      begin
        data = JSON.parse(body)
      rescue JSON::ParserError => e
        log_entry["error"] = "Invalid JSON response: #{e.message}"
        write_log(log_file, log_entry)
        raise RuntimeError, "Invalid JSON response: #{e.message}"
      end

      log_entry["response"] = data
      log_entry["ok"] = data["result"] == "OK"
      write_log(log_file, log_entry)

      # For HTTP errors (4xx/5xx), kwtSMS returns JSON error details in the body.
      # If we successfully parsed the JSON, return it like a normal response.
      return data

    rescue Net::OpenTimeout, Net::ReadTimeout => e
      err = "Network error: connection timed out"
      log_entry["error"] = err
      write_log(log_file, log_entry)
      raise RuntimeError, err

    rescue SocketError, Errno::ECONNREFUSED, Errno::EHOSTUNREACH, IOError => e
      err = "Network error: #{e.message}"
      log_entry["error"] = err
      write_log(log_file, log_entry)
      raise RuntimeError, err
    end
  end
end
