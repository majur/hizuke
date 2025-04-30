# frozen_string_literal: true

require_relative 'constants'
require_relative 'date_calculator'
require_relative 'holidays'
require_relative 'holiday_matcher'
require_relative 'pattern_matcher'
require 'date'

module Hizuke
  # TimeOfDay represents a time with hour, minute and second
  class TimeOfDay
    attr_reader :hour, :min, :sec

    def initialize(hour, min, sec)
      @hour = hour
      @min = min
      @sec = sec
    end

    def to_s
      # Include seconds in the format if they are not zero
      if sec.zero?
        format('%<hour>02d:%<min>02d', hour: hour, min: min)
      else
        format('%<hour>02d:%<min>02d:%<sec>02d', hour: hour, min: min, sec: sec)
      end
    end
  end

  # Result represents a parsing result with clean text and parsed date
  class Result
    attr_reader :clean_text, :date, :time

    def initialize(clean_text, date, time = nil)
      @clean_text = clean_text
      @date = date
      @time = time
    end

    # Alias for clean_text for backward compatibility
    alias text clean_text

    # Returns a DateTime object if time is available, otherwise nil
    def datetime
      return nil unless @time && @date

      DateTime.new(@date.year, @date.month, @date.day, @time.hour, @time.min, @time.sec)
    end
  end

  # Error raised when parsing fails
  class ParseError < StandardError; end

  # Main parser class for the Hizuke library
  # Supports parsing dates from text with references like:
  # - today, tomorrow, yesterday
  # - next Monday, this Tuesday, last Friday
  # - in 3 days, 2 weeks ago
  # - next week, last month, end of year
  # - holidays like Christmas, Easter, Thanksgiving
  # - at 10:30, noon, midnight
  class Parser
    include Constants
    include DateCalculator
    include WeekCalculator
    include MonthCalculator
    include YearCalculator
    include QuarterCalculator
    include PeriodCalculator
    include HolidayMatcher
    include PatternMatcher

    # Parse a date from text - class method
    # @param text [String] the text to parse
    # @return [Hizuke::Result] the parsing result with clean text and date
    def self.parse(text)
      new.parse(text)
    end

    # Parse a date with result details from text - class method
    # @param text [String] the text to parse
    # @return [Hizuke::Result] the parsing result with clean text and date
    def self.parse_with_result(text)
      new.parse_with_result(text)
    end

    # Parse a date from text
    # @param text [String] the text to parse
    # @return [Hizuke::Result] the parsing result with clean text and date
    def parse(text)
      raise ParseError, 'Cannot parse nil input' if text.nil?
      raise ParseError, 'Cannot parse empty input' if text.empty?

      parse_with_result(text)
    end

    # Parse a date with result details from text
    # @param text [String] the text to parse
    # @return [Hizuke::Result] the parsing result with clean text and date
    def parse_with_result(text)
      raise ParseError, 'Cannot parse nil input' if text.nil?
      raise ParseError, 'Cannot parse empty input' if text.empty?

      # Extract any time references
      time, clean_text = extract_time_references(text)

      # Try to parse a date from the cleaned text
      result = try_parsing_strategies(clean_text)

      # Add the time if extracted
      Result.new(result.clean_text, result.date, time)
    end
  end
end
