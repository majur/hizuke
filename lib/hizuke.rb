# frozen_string_literal: true

require_relative 'hizuke/version'
require_relative 'hizuke/parser'

# Hizuke is a simple date parser that extracts dates from text
# containing time references like "yesterday", "today", and "tomorrow".
#
# Example:
#   result = Hizuke.parse("wash car tomorrow")
#   result.text  # => "wash car"
#   result.date  # => <Date: 2023-04-01>
module Hizuke
  # Parse text containing time references and extract both
  # the clean text and the date.
  #
  # @param text [String] the text to parse
  # @return [Hizuke::Result] the parsing result containing text and date
  def self.parse(text)
    Parser.parse(text)
  end

  # Error raised when parsing fails
  class ParseError < StandardError; end
end
