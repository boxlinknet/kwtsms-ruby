# frozen_string_literal: true

module KwtSMS
  # Load key=value pairs from a .env file. Returns empty hash if not found.
  # Never raises. Never modifies ENV.
  def self.load_env_file(env_file = ".env")
    env = {}
    begin
      File.foreach(env_file, encoding: "utf-8") do |line|
        line = line.strip
        next if line.empty? || line.start_with?("#")
        next unless line.include?("=")

        key, _, value = line.partition("=")
        val = value.strip

        # Strip inline comments from unquoted values
        unless val.start_with?('"') || val.start_with?("'")
          val = val.sub(/\s+#.*\z/, "")
        end

        # Strip one matching outer quote pair
        if val.length >= 2 && val[0] == val[-1] && (val[0] == '"' || val[0] == "'")
          val = val[1..-2]
        end

        env[key.strip] = val
      end
    rescue Errno::ENOENT
      # File not found, return empty hash silently
    end
    env
  end
end
