# frozen_string_literal: true

module KwtSMS
  # Arabic-Indic digits (U+0660..U+0669) and Extended Arabic-Indic / Persian digits (U+06F0..U+06F9)
  ARABIC_DIGITS = "\u0660\u0661\u0662\u0663\u0664\u0665\u0666\u0667\u0668\u0669"
  EXTENDED_ARABIC_DIGITS = "\u06F0\u06F1\u06F2\u06F3\u06F4\u06F5\u06F6\u06F7\u06F8\u06F9"
  LATIN_DIGITS = "01234567890123456789"

  # Phone number validation rules by country code.
  # Validates local number length and mobile starting digits.
  #
  # localLengths: valid digit count(s) AFTER country code
  # mobileStartDigits: valid first character(s) of the local number (nil = any)
  #
  # Countries not listed here pass through with generic E.164 validation (7-15 digits).
  PHONE_RULES = {
    # GCC
    "965" => { local_lengths: [8], mobile_start: %w[4 5 6 9] },       # Kuwait
    "966" => { local_lengths: [9], mobile_start: %w[5] },              # Saudi Arabia
    "971" => { local_lengths: [9], mobile_start: %w[5] },              # UAE
    "973" => { local_lengths: [8], mobile_start: %w[3 6] },            # Bahrain
    "974" => { local_lengths: [8], mobile_start: %w[3 5 6 7] },        # Qatar
    "968" => { local_lengths: [8], mobile_start: %w[7 9] },            # Oman
    # Levant
    "962" => { local_lengths: [9], mobile_start: %w[7] },              # Jordan
    "961" => { local_lengths: [7, 8], mobile_start: %w[3 7 8] },       # Lebanon
    "970" => { local_lengths: [9], mobile_start: %w[5] },              # Palestine
    "964" => { local_lengths: [10], mobile_start: %w[7] },             # Iraq
    "963" => { local_lengths: [9], mobile_start: %w[9] },              # Syria
    # Other Arab
    "967" => { local_lengths: [9], mobile_start: %w[7] },              # Yemen
    "20"  => { local_lengths: [10], mobile_start: %w[1] },             # Egypt
    "218" => { local_lengths: [9], mobile_start: %w[9] },              # Libya
    "216" => { local_lengths: [8], mobile_start: %w[2 4 5 9] },        # Tunisia
    "212" => { local_lengths: [9], mobile_start: %w[6 7] },            # Morocco
    "213" => { local_lengths: [9], mobile_start: %w[5 6 7] },          # Algeria
    "249" => { local_lengths: [9], mobile_start: %w[9] },              # Sudan
    # Non-Arab Middle East
    "98"  => { local_lengths: [10], mobile_start: %w[9] },             # Iran
    "90"  => { local_lengths: [10], mobile_start: %w[5] },             # Turkey
    "972" => { local_lengths: [9], mobile_start: %w[5] },              # Israel
    # South Asia
    "91"  => { local_lengths: [10], mobile_start: %w[6 7 8 9] },       # India
    "92"  => { local_lengths: [10], mobile_start: %w[3] },             # Pakistan
    "880" => { local_lengths: [10], mobile_start: %w[1] },             # Bangladesh
    "94"  => { local_lengths: [9], mobile_start: %w[7] },              # Sri Lanka
    "960" => { local_lengths: [7], mobile_start: %w[7 9] },            # Maldives
    # East Asia
    "86"  => { local_lengths: [11], mobile_start: %w[1] },             # China
    "81"  => { local_lengths: [10], mobile_start: %w[7 8 9] },         # Japan
    "82"  => { local_lengths: [10], mobile_start: %w[1] },             # South Korea
    "886" => { local_lengths: [9], mobile_start: %w[9] },              # Taiwan
    # Southeast Asia
    "65"  => { local_lengths: [8], mobile_start: %w[8 9] },            # Singapore
    "60"  => { local_lengths: [9, 10], mobile_start: %w[1] },          # Malaysia
    "62"  => { local_lengths: [9, 10, 11, 12], mobile_start: %w[8] },  # Indonesia
    "63"  => { local_lengths: [10], mobile_start: %w[9] },             # Philippines
    "66"  => { local_lengths: [9], mobile_start: %w[6 8 9] },          # Thailand
    "84"  => { local_lengths: [9], mobile_start: %w[3 5 7 8 9] },      # Vietnam
    "95"  => { local_lengths: [9], mobile_start: %w[9] },              # Myanmar
    "855" => { local_lengths: [8, 9], mobile_start: %w[1 6 7 8 9] },   # Cambodia
    "976" => { local_lengths: [8], mobile_start: %w[6 8 9] },          # Mongolia
    # Europe
    "44"  => { local_lengths: [10], mobile_start: %w[7] },             # UK
    "33"  => { local_lengths: [9], mobile_start: %w[6 7] },            # France
    "49"  => { local_lengths: [10, 11], mobile_start: %w[1] },         # Germany
    "39"  => { local_lengths: [10], mobile_start: %w[3] },             # Italy
    "34"  => { local_lengths: [9], mobile_start: %w[6 7] },            # Spain
    "31"  => { local_lengths: [9], mobile_start: %w[6] },              # Netherlands
    "32"  => { local_lengths: [9], mobile_start: nil },                 # Belgium
    "41"  => { local_lengths: [9], mobile_start: %w[7] },              # Switzerland
    "43"  => { local_lengths: [10], mobile_start: %w[6] },             # Austria
    "47"  => { local_lengths: [8], mobile_start: %w[4 9] },            # Norway
    "48"  => { local_lengths: [9], mobile_start: nil },                 # Poland
    "30"  => { local_lengths: [10], mobile_start: %w[6] },             # Greece
    "420" => { local_lengths: [9], mobile_start: %w[6 7] },            # Czech Republic
    "46"  => { local_lengths: [9], mobile_start: %w[7] },              # Sweden
    "45"  => { local_lengths: [8], mobile_start: nil },                 # Denmark
    "40"  => { local_lengths: [9], mobile_start: %w[7] },              # Romania
    "36"  => { local_lengths: [9], mobile_start: nil },                 # Hungary
    "380" => { local_lengths: [9], mobile_start: nil },                 # Ukraine
    # Americas
    "1"   => { local_lengths: [10], mobile_start: nil },                # USA/Canada
    "52"  => { local_lengths: [10], mobile_start: nil },                # Mexico
    "55"  => { local_lengths: [11], mobile_start: nil },                # Brazil
    "57"  => { local_lengths: [10], mobile_start: %w[3] },             # Colombia
    "54"  => { local_lengths: [10], mobile_start: %w[9] },             # Argentina
    "56"  => { local_lengths: [9], mobile_start: %w[9] },              # Chile
    "58"  => { local_lengths: [10], mobile_start: %w[4] },             # Venezuela
    "51"  => { local_lengths: [9], mobile_start: %w[9] },              # Peru
    "593" => { local_lengths: [9], mobile_start: %w[9] },              # Ecuador
    "53"  => { local_lengths: [8], mobile_start: %w[5 6] },            # Cuba
    # Africa
    "27"  => { local_lengths: [9], mobile_start: %w[6 7 8] },          # South Africa
    "234" => { local_lengths: [10], mobile_start: %w[7 8 9] },         # Nigeria
    "254" => { local_lengths: [9], mobile_start: %w[1 7] },            # Kenya
    "233" => { local_lengths: [9], mobile_start: %w[2 5] },            # Ghana
    "251" => { local_lengths: [9], mobile_start: %w[7 9] },            # Ethiopia
    "255" => { local_lengths: [9], mobile_start: %w[6 7] },            # Tanzania
    "256" => { local_lengths: [9], mobile_start: %w[7] },              # Uganda
    "237" => { local_lengths: [9], mobile_start: %w[6] },              # Cameroon
    "225" => { local_lengths: [10], mobile_start: nil },                # Ivory Coast
    "221" => { local_lengths: [9], mobile_start: %w[7] },              # Senegal
    "252" => { local_lengths: [9], mobile_start: %w[6 7] },            # Somalia
    "250" => { local_lengths: [9], mobile_start: %w[7] },              # Rwanda
    # Oceania
    "61"  => { local_lengths: [9], mobile_start: %w[4] },              # Australia
    "64"  => { local_lengths: [8, 9, 10], mobile_start: %w[2] },       # New Zealand
  }.freeze

  COUNTRY_NAMES = {
    "965" => "Kuwait", "966" => "Saudi Arabia", "971" => "UAE", "973" => "Bahrain",
    "974" => "Qatar", "968" => "Oman", "962" => "Jordan", "961" => "Lebanon",
    "970" => "Palestine", "964" => "Iraq", "963" => "Syria", "967" => "Yemen",
    "98" => "Iran", "90" => "Turkey", "972" => "Israel", "20" => "Egypt",
    "218" => "Libya", "216" => "Tunisia", "212" => "Morocco", "213" => "Algeria",
    "249" => "Sudan", "91" => "India", "92" => "Pakistan", "880" => "Bangladesh",
    "94" => "Sri Lanka", "960" => "Maldives", "86" => "China", "81" => "Japan",
    "82" => "South Korea", "886" => "Taiwan", "65" => "Singapore", "60" => "Malaysia",
    "62" => "Indonesia", "63" => "Philippines", "66" => "Thailand", "84" => "Vietnam",
    "95" => "Myanmar", "855" => "Cambodia", "976" => "Mongolia",
    "44" => "UK", "33" => "France", "49" => "Germany", "39" => "Italy",
    "34" => "Spain", "31" => "Netherlands", "32" => "Belgium", "41" => "Switzerland",
    "43" => "Austria", "47" => "Norway", "48" => "Poland", "30" => "Greece",
    "420" => "Czech Republic", "46" => "Sweden", "45" => "Denmark", "40" => "Romania",
    "36" => "Hungary", "380" => "Ukraine",
    "1" => "USA/Canada", "52" => "Mexico", "55" => "Brazil", "57" => "Colombia",
    "54" => "Argentina", "56" => "Chile", "58" => "Venezuela", "51" => "Peru",
    "593" => "Ecuador", "53" => "Cuba",
    "27" => "South Africa", "234" => "Nigeria", "254" => "Kenya", "233" => "Ghana",
    "251" => "Ethiopia", "255" => "Tanzania", "256" => "Uganda", "237" => "Cameroon",
    "225" => "Ivory Coast", "221" => "Senegal", "252" => "Somalia", "250" => "Rwanda",
    "61" => "Australia", "64" => "New Zealand",
  }.freeze

  # Find the country code prefix from a normalized phone number.
  # Tries 3-digit codes first, then 2-digit, then 1-digit (longest match wins).
  def self.find_country_code(normalized)
    if normalized.length >= 3
      cc3 = normalized[0, 3]
      return cc3 if PHONE_RULES.key?(cc3)
    end
    if normalized.length >= 2
      cc2 = normalized[0, 2]
      return cc2 if PHONE_RULES.key?(cc2)
    end
    if normalized.length >= 1
      cc1 = normalized[0, 1]
      return cc1 if PHONE_RULES.key?(cc1)
    end
    nil
  end

  # Validate a normalized phone number against country-specific format rules.
  # Checks local number length and mobile starting digits.
  # Numbers with no matching country rules pass through (generic E.164 only).
  #
  # Returns: [valid, error]
  def self.validate_phone_format(normalized)
    cc = find_country_code(normalized)
    return [true, nil] unless cc

    rule = PHONE_RULES[cc]
    local = normalized[cc.length..]
    country = COUNTRY_NAMES[cc] || "+#{cc}"

    unless rule[:local_lengths].include?(local.length)
      expected = rule[:local_lengths].join(" or ")
      return [false, "Invalid #{country} number: expected #{expected} digits after +#{cc}, got #{local.length}"]
    end

    if rule[:mobile_start] && !rule[:mobile_start].empty?
      unless rule[:mobile_start].any? { |prefix| local.start_with?(prefix) }
        return [false, "Invalid #{country} mobile number: after +#{cc} must start with #{rule[:mobile_start].join(', ')}"]
      end
    end

    [true, nil]
  end

  # Normalize phone to kwtSMS format: digits only, no leading zeros.
  # Converts Arabic-Indic and Extended Arabic-Indic digits to Latin,
  # strips all non-digit characters, strips leading zeros,
  # strips domestic trunk prefix after country code (e.g. 9660559... -> 966559...).
  def self.normalize_phone(phone)
    phone = phone.to_s
    # 1. Convert Arabic-Indic and Extended Arabic-Indic digits to Latin
    phone = phone.tr(ARABIC_DIGITS + EXTENDED_ARABIC_DIGITS, LATIN_DIGITS)
    # 2. Strip every non-digit character
    phone = phone.gsub(/\D/, "")
    # 3. Strip leading zeros
    phone = phone.sub(/\A0+/, "")
    # 4. Strip domestic trunk prefix (leading 0 after country code)
    #    e.g. 9660559... -> 966559..., 97105x -> 9715x
    cc = find_country_code(phone)
    if cc
      local = phone[cc.length..]
      if local && local.start_with?("0")
        phone = cc + local.sub(/\A0+/, "")
      end
    end
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
  # - Country-specific format errors (wrong length, wrong mobile prefix)
  def self.validate_phone_input(phone)
    raw = phone.to_s.strip

    # 1. Empty / blank
    return [false, "Phone number is required", ""] if raw.empty?

    # Sanitize raw input for safe interpolation in error messages:
    # strip control chars and truncate to prevent log injection
    safe = raw.gsub(/[[:cntrl:]]/, "")[0, 50]

    # 2. Email address entered by mistake
    return [false, "'#{safe}' is an email address, not a phone number", ""] if raw.include?("@")

    # 3. Normalize
    normalized = normalize_phone(raw)

    # 4. No digits survived normalization
    return [false, "'#{safe}' is not a valid phone number, no digits found", ""] if normalized.empty?

    # 5. Too short
    if normalized.length < 7
      digit_word = normalized.length == 1 ? "digit" : "digits"
      return [false, "'#{safe}' is too short to be a valid phone number (#{normalized.length} #{digit_word}, minimum is 7)", normalized]
    end

    # 6. Too long
    if normalized.length > 15
      return [false, "'#{safe}' is too long to be a valid phone number (#{normalized.length} digits, maximum is 15)", normalized]
    end

    # 7. Country-specific format validation
    format_valid, format_error = validate_phone_format(normalized)
    return [false, format_error, normalized] unless format_valid

    [true, nil, normalized]
  end
end
