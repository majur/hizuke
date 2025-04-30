# frozen_string_literal: true

require_relative 'hizuke/version'
require_relative 'hizuke/constants'
require_relative 'hizuke/date_calculator'
require_relative 'hizuke/holidays'
require_relative 'hizuke/holiday_matcher'
require_relative 'hizuke/pattern_matcher'
require_relative 'hizuke/parser'

# Hizuke is a simple date parser that extracts dates from tex
# containing time references like "yesterday", "today", and "tomorrow".
#
# Example:
#   result = Hizuke.parse("wash car tomorrow")
#   result.text  # => "wash car"
#   result.date  # => <Date: 2023-04-01>
module Hizuke
  # Configuration class to hold Hizuke settings
  class Configuration
    attr_accessor :morning_time, :evening_time

    def initialize
      @morning_time = { hour: 8, min: 0 }
      @evening_time = { hour: 20, min: 0 }
    end
  end

  # Returns the current configuration
  # @return [Hizuke::Configuration] the current configuration
  def self.configuration
    @configuration ||= Configuration.new
  end

  # Configure Hizuke settings
  # @yield [config] Gives the configuration object to the block
  # @return [Hizuke::Configuration] the updated configuration
  def self.configure
    yield(configuration)
    configuration
  end

  # Parse text containing time references and extract both
  # the clean text and the date.
  #
  # @param text [String] the text to parse
  # @return [Hizuke::Result] the parsing result containing text and date
  def self.parse(text)
    raise ParseError, 'Cannot parse nil input' if text.nil?
    raise ParseError, 'Cannot parse empty input' if text.empty?

    Parser.parse(text)
  end

  # Error raised when parsing fails
  class ParseError < StandardError; end
end
