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
    valid, error, normalized = KwtSMS.validate_phone_input("5")
    refute valid
    assert_includes error, "1 digit"
  end

  def test_too_long
    valid, error, normalized = KwtSMS.validate_phone_input("1234567890123456")
    refute valid
    assert_includes error, "too long"
    assert_includes error, "16 digits"
  end

  def test_minimum_valid_7_digits
    valid, error, normalized = KwtSMS.validate_phone_input("1234567")
    assert valid
    assert_nil error
    assert_equal "1234567", normalized
  end

  def test_maximum_valid_15_digits
    valid, error, normalized = KwtSMS.validate_phone_input("123456789012345")
    assert valid
    assert_nil error
    assert_equal "123456789012345", normalized
  end

  def test_arabic_digits_valid
    valid, error, normalized = KwtSMS.validate_phone_input("\u0669\u0666\u0665\u0669\u0668\u0667\u0666\u0665\u0664\u0663\u0662")
    assert valid
    assert_nil error
    assert_equal "96598765432", normalized
  end

  def test_nil_input
    valid, error, normalized = KwtSMS.validate_phone_input(nil)
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
end
