# frozen_string_literal: true

module KwtSMS
  # Arabic-Indic digits (U+0660..U+0669) and Extended Arabic-Indic / Persian digits (U+06F0..U+06F9)
  ARABIC_DIGITS = "\u0660\u0661\u0662\u0663\u0664\u0665\u0666\u0667\u0668\u0669"
  EXTENDED_ARABIC_DIGITS = "\u06F0\u06F1\u06F2\u06F3\u06F4\u06F5\u06F6\u06F7\u06F8\u06F9"
  LATIN_DIGITS = "01234567890123456789"

  # Normalize phone to kwtSMS format: digits only, no leading zeros.
  # Converts Arabic-Indic and Extended Arabic-Indic digits to Latin,
  # strips all non-digit characters, strips leading zeros.
  def self.normalize_phone(phone)
    phone = phone.to_s
    # 1. Convert Arabic-Indic and Extended Arabic-Indic digits to Latin
    phone = phone.tr(ARABIC_DIGITS + EXTENDED_ARABIC_DIGITS, LATIN_DIGITS)
    # 2. Strip every non-digit character
    phone = phone.gsub(/\D/, "")
    # 3. Strip leading zeros
    phone = phone.sub(/\A0+/, "")
    phone
  end

  # Validate a raw phone number input before sending to the kwtSMS API.
  #
  # Returns: [is_valid, error, normalized]
  #   is_valid:   true/false
  #   error:      nil or error message string
  #   normalized: normalized phone string
  #
  # Catches every common mistake without crashing:
  # - Empty or blank input
  # - Email address entered instead of a phone number
  # - Non-numeric text with no digits
  # - Too short after normalization (< 7 digits)
  # - Too long after normalization (> 15 digits, E.164 maximum)
  def self.validate_phone_input(phone)
    raw = phone.to_s.strip

    # 1. Empty / blank
    return [false, "Phone number is required", ""] if raw.empty?

    # 2. Email address entered by mistake
    return [false, "'#{raw}' is an email address, not a phone number", ""] if raw.include?("@")

    # 3. Normalize
    normalized = normalize_phone(raw)

    # 4. No digits survived normalization
    return [false, "'#{raw}' is not a valid phone number, no digits found", ""] if normalized.empty?

    # 5. Too short
    if normalized.length < 7
      digit_word = normalized.length == 1 ? "digit" : "digits"
      return [false, "'#{raw}' is too short to be a valid phone number (#{normalized.length} #{digit_word}, minimum is 7)", normalized]
    end

    # 6. Too long
    if normalized.length > 15
      return [false, "'#{raw}' is too long to be a valid phone number (#{normalized.length} digits, maximum is 15)", normalized]
    end

    [true, nil, normalized]
  end
end
