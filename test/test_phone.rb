# frozen_string_literal: true

require_relative "test_helper"

class TestNormalizePhone < Minitest::Test
  def test_strips_plus_prefix
    assert_equal "96598765432", KwtSMS.normalize_phone("+96598765432")
  end

  def test_strips_double_zero_prefix
    assert_equal "96598765432", KwtSMS.normalize_phone("0096598765432")
  end

  def test_strips_spaces
    assert_equal "96598765432", KwtSMS.normalize_phone("+965 9876 5432")
  end

  def test_strips_dashes
    assert_equal "96598765432", KwtSMS.normalize_phone("+965-9876-5432")
  end

  def test_strips_dots
    assert_equal "96598765432", KwtSMS.normalize_phone("965.9876.5432")
  end

  def test_strips_parentheses
    assert_equal "96598765432", KwtSMS.normalize_phone("(965) 98765432")
  end

  def test_strips_leading_zeros
    assert_equal "96598765432", KwtSMS.normalize_phone("00096598765432")
  end

  def test_converts_arabic_indic_digits
    assert_equal "96598765432", KwtSMS.normalize_phone("\u0669\u0666\u0665\u0669\u0668\u0667\u0666\u0665\u0664\u0663\u0662")
  end

  def test_converts_extended_arabic_indic_digits
    assert_equal "96598765432", KwtSMS.normalize_phone("\u06F9\u06F6\u06F5\u06F9\u06F8\u06F7\u06F6\u06F5\u06F4\u06F3\u06F2")
  end

  def test_empty_string
    assert_equal "", KwtSMS.normalize_phone("")
  end

  def test_non_string_input
    assert_equal "12345", KwtSMS.normalize_phone(12345)
  end

  def test_all_non_digits
    assert_equal "", KwtSMS.normalize_phone("abc-xyz")
  end

  def test_mixed_formats
    assert_equal "96598765432", KwtSMS.normalize_phone("  +965 (98) 765-432  ")
  end

  # Trunk prefix stripping
  def test_strips_saudi_trunk_zero
    assert_equal "966559123456", KwtSMS.normalize_phone("9660559123456")
  end

  def test_strips_saudi_trunk_zero_with_plus
    assert_equal "966559123456", KwtSMS.normalize_phone("+9660559123456")
  end

  def test_strips_saudi_trunk_zero_with_double_zero
    assert_equal "966559123456", KwtSMS.normalize_phone("009660559123456")
  end

  def test_strips_uae_trunk_zero
    assert_equal "971501234567", KwtSMS.normalize_phone("9710501234567")
  end

  def test_strips_egypt_trunk_zero
    assert_equal "201012345678", KwtSMS.normalize_phone("2001012345678")
  end

  def test_no_trunk_strip_when_no_zero
    assert_equal "966559123456", KwtSMS.normalize_phone("966559123456")
  end

  def test_kuwait_no_trunk_strip
    assert_equal "96598765432", KwtSMS.normalize_phone("96598765432")
  end
end

class TestValidatePhoneInput < Minitest::Test
  def test_valid_international
    valid, error, normalized = KwtSMS.validate_phone_input("+96598765432")
    assert valid
    assert_nil error
    assert_equal "96598765432", normalized
  end

  def test_valid_with_double_zero
    valid, error, normalized = KwtSMS.validate_phone_input("0096598765432")
    assert valid
    assert_nil error
    assert_equal "96598765432", normalized
  end

  def test_empty_string
    valid, error, normalized = KwtSMS.validate_phone_input("")
    refute valid
    assert_equal "Phone number is required", error
    assert_equal "", normalized
  end

  def test_blank_string
    valid, error, normalized = KwtSMS.validate_phone_input("   ")
    refute valid
    assert_equal "Phone number is required", error
    assert_equal "", normalized
  end

  def test_email_address
    valid, error, normalized = KwtSMS.validate_phone_input("user@gmail.com")
    refute valid
    assert_includes error, "email address"
    assert_equal "", normalized
  end

  def test_no_digits
    valid, error, normalized = KwtSMS.validate_phone_input("abc")
    refute valid
    assert_includes error, "no digits found"
    assert_equal "", normalized
  end

  def test_too_short
    valid, error, normalized = KwtSMS.validate_phone_input("123")
    refute valid
    assert_includes error, "too short"
    assert_includes error, "3 digits"
    assert_equal "123", normalized
  end

  def test_single_digit_too_short
    valid, error, _normalized = KwtSMS.validate_phone_input("5")
    refute valid
    assert_includes error, "1 digit"
  end

  def test_too_long
    valid, error, _normalized = KwtSMS.validate_phone_input("1234567890123456")
    refute valid
    assert_includes error, "too long"
    assert_includes error, "16 digits"
  end

  def test_minimum_valid_7_digits
    # Use a number that doesn't match any country code (generic E.164)
    valid, error, normalized = KwtSMS.validate_phone_input("9991234")
    assert valid
    assert_nil error
    assert_equal "9991234", normalized
  end

  def test_maximum_valid_15_digits
    # Use a number that doesn't match any country code (generic E.164)
    valid, error, normalized = KwtSMS.validate_phone_input("999123456789012")
    assert valid
    assert_nil error
    assert_equal "999123456789012", normalized
  end

  def test_arabic_digits_valid
    valid, error, normalized = KwtSMS.validate_phone_input("\u0669\u0666\u0665\u0669\u0668\u0667\u0666\u0665\u0664\u0663\u0662")
    assert valid
    assert_nil error
    assert_equal "96598765432", normalized
  end

  def test_nil_input
    valid, error, _normalized = KwtSMS.validate_phone_input(nil)
    refute valid
    assert_equal "Phone number is required", error
  end

  def test_numeric_input
    valid, error, normalized = KwtSMS.validate_phone_input(96598765432)
    assert valid
    assert_nil error
    assert_equal "96598765432", normalized
  end

  def test_dashes_only
    valid, error, = KwtSMS.validate_phone_input("---")
    refute valid
    assert_includes error, "no digits found"
  end

  # Saudi trunk zero stripping
  def test_saudi_with_trunk_zero
    valid, error, normalized = KwtSMS.validate_phone_input("9660559123456")
    assert valid
    assert_nil error
    assert_equal "966559123456", normalized
  end

  def test_saudi_with_plus_trunk_zero
    valid, error, normalized = KwtSMS.validate_phone_input("+9660559123456")
    assert valid
    assert_nil error
    assert_equal "966559123456", normalized
  end

  def test_saudi_with_00_trunk_zero
    valid, error, normalized = KwtSMS.validate_phone_input("009660559123456")
    assert valid
    assert_nil error
    assert_equal "966559123456", normalized
  end
end

class TestFindCountryCode < Minitest::Test
  def test_3_digit_code
    assert_equal "965", KwtSMS.find_country_code("96598765432")
  end

  def test_2_digit_code
    assert_equal "44", KwtSMS.find_country_code("447911123456")
  end

  def test_1_digit_code
    assert_equal "1", KwtSMS.find_country_code("12025551234")
  end

  def test_unknown_code
    assert_nil KwtSMS.find_country_code("9991234567")
  end

  def test_empty_string
    assert_nil KwtSMS.find_country_code("")
  end

  def test_prefers_longest_match
    # 420 = Czech Republic (3-digit), not 42 (unassigned)
    assert_equal "420", KwtSMS.find_country_code("420612345678")
  end
end

class TestValidatePhoneFormat < Minitest::Test
  # Kuwait
  def test_valid_kuwait_mobile
    valid, error = KwtSMS.validate_phone_format("96598765432")
    assert valid
    assert_nil error
  end

  def test_kuwait_wrong_length
    valid, error = KwtSMS.validate_phone_format("9659876543")
    refute valid
    assert_includes error, "Kuwait"
    assert_includes error, "8 digits"
  end

  def test_kuwait_wrong_prefix
    valid, error = KwtSMS.validate_phone_format("96528765432")
    refute valid
    assert_includes error, "Kuwait"
    assert_includes error, "mobile"
  end

  def test_kuwait_all_valid_prefixes
    %w[4 5 6 9].each do |d|
      valid, _error = KwtSMS.validate_phone_format("965#{d}8765432")
      assert valid, "Kuwait prefix #{d} should be valid"
    end
  end

  # Saudi Arabia
  def test_valid_saudi_mobile
    valid, error = KwtSMS.validate_phone_format("966559123456")
    assert valid
    assert_nil error
  end

  def test_saudi_wrong_length
    valid, error = KwtSMS.validate_phone_format("96655912345")
    refute valid
    assert_includes error, "Saudi"
    assert_includes error, "9 digits"
  end

  def test_saudi_wrong_prefix
    valid, error = KwtSMS.validate_phone_format("966359123456")
    refute valid
    assert_includes error, "Saudi"
    assert_includes error, "mobile"
  end

  # UAE
  def test_valid_uae_mobile
    valid, error = KwtSMS.validate_phone_format("971501234567")
    assert valid
    assert_nil error
  end

  # Egypt
  def test_valid_egypt_mobile
    valid, error = KwtSMS.validate_phone_format("201012345678")
    assert valid
    assert_nil error
  end

  # USA (no mobile prefix check)
  def test_valid_usa_number
    valid, error = KwtSMS.validate_phone_format("12025551234")
    assert valid
    assert_nil error
  end

  def test_usa_wrong_length
    valid, error = KwtSMS.validate_phone_format("1202555123")
    refute valid
    assert_includes error, "USA"
    assert_includes error, "10 digits"
  end

  # Unknown country code passes through
  def test_unknown_country_passes
    valid, error = KwtSMS.validate_phone_format("9991234567890")
    assert valid
    assert_nil error
  end

  # Countries with nil mobile_start (length-only check)
  def test_belgium_any_prefix
    valid, error = KwtSMS.validate_phone_format("32412345678")
    assert valid
    assert_nil error
  end

  def test_poland_any_prefix
    valid, error = KwtSMS.validate_phone_format("48512345678")
    assert valid
    assert_nil error
  end

  # India
  def test_valid_india_mobile
    valid, error = KwtSMS.validate_phone_format("919876543210")
    assert valid
    assert_nil error
  end

  def test_india_wrong_prefix
    valid, error = KwtSMS.validate_phone_format("911234567890")
    refute valid
    assert_includes error, "India"
    assert_includes error, "mobile"
  end

  # UK
  def test_valid_uk_mobile
    valid, error = KwtSMS.validate_phone_format("447911123456")
    assert valid
    assert_nil error
  end
end
