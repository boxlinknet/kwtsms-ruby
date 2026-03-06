# frozen_string_literal: true

require "json"
require "time"

module KwtSMS
  # Append a JSONL log entry. Never raises. Logging must not break main flow.
  def self.write_log(log_file, entry)
    return if log_file.nil? || log_file.empty?

    begin
      File.open(log_file, "a", encoding: "utf-8") do |f|
        f.puts(JSON.generate(entry))
      end
    rescue StandardError
      # Logging must never crash the main flow
    end
  end
end
