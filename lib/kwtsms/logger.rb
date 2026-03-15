# frozen_string_literal: true

require "json"
require "time"

module KwtSMS
  # Validate a log file path. Returns [valid, error].
  # Rejects path traversal, absolute paths outside CWD, and device paths.
  def self.validate_log_path(log_file)
    return [false, "log_file must be a String"] unless log_file.is_a?(String)
    return [false, "log_file must not be empty"] if log_file.strip.empty?
    return [false, "log_file must not contain '..'"] if log_file.include?("..")
    return [false, "log_file must not contain null bytes"] if log_file.include?("\0")
    return [false, "log_file must not start with /"] if log_file.start_with?("/")
    return [false, "log_file must not start with ~"] if log_file.start_with?("~")
    return [false, "log_file must not be a pipe or device"] if log_file.start_with?("|") || log_file.match?(%r{\A/dev/})

    [true, nil]
  end

  # Append a JSONL log entry. Never raises. Logging must not break main flow.
  def self.write_log(log_file, entry)
    return if log_file.nil? || log_file.empty?

    valid, = validate_log_path(log_file)
    return unless valid

    begin
      File.open(log_file, "a", encoding: "utf-8") do |f|
        f.puts(JSON.generate(entry))
      end
    rescue StandardError
      # Logging must never crash the main flow
    end
  end
end
