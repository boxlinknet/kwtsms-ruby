# frozen_string_literal: true

# kwtsms: Ruby client for the kwtSMS API (kwtsms.com)
#
# Quick start:
#   require "kwtsms"
#
#   sms = KwtSMS::Client.from_env                          # reads .env / env vars
#   ok, balance, err = sms.verify
#   result = sms.send_sms("96598765432", "Your OTP is: 123456")
#   result = sms.send_sms("96598765432", "Hello", sender: "MY-APP")
#   balance = sms.balance
#
# Utility functions:
#   KwtSMS.normalize_phone("+965 9876 5432")
#   KwtSMS.validate_phone_input("user@email.com")
#   KwtSMS.clean_message("Hello \u{1F600} world")

require "set"

require_relative "kwtsms/version"
require_relative "kwtsms/errors"
require_relative "kwtsms/phone"
require_relative "kwtsms/message"
require_relative "kwtsms/env_loader"
require_relative "kwtsms/logger"
require_relative "kwtsms/request"
require_relative "kwtsms/client"
