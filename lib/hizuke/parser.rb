# frozen_string_literal: true

require 'date'
require 'time'
require_relative 'constants'
require_relative 'date_calculator'
require_relative 'pattern_matcher'

# Main module for Hizuke date extraction library
module Hizuke
  # Simple class to represent a time of day without a date
  class TimeOfDay
    attr_reader :hour, :min, :sec

    def initialize(hour, min = 0, sec = 0)
      @hour = hour
      @min = min
      @sec = sec
    end

    def to_s
      if sec.zero?
        format('%<hour>02d:%<min>02d', hour: hour, min: min)
      else
        format('%<hour>02d:%<min>02d:%<sec>02d', hour: hour, min: min, sec: sec)
      end
    end

    def inspect
      to_s
    end
  end

  # Result object containing the clean text and extracted date/time
  class Result
    attr_reader :text, :date, :time

    def initialize(text, date, time = nil)
      @text = text
      @date = date
      @time = time
    end

    def datetime
      return nil unless @time

      # Combine date and time into a Time object
      Time.new(@date.year, @date.month, @date.day,
               @time.hour, @time.min, @time.sec)
    end
  end

  # Configuration class for Hizuke
  class Configuration
    attr_accessor :morning_time, :evening_time

    def initialize
      @morning_time = { hour: 8, min: 0 }
      @evening_time = { hour: 20, min: 0 }
    end
  end

  # Allows configuration of Hizuke
  def self.configure
    @configuration ||= Configuration.new
    yield(@configuration) if block_given?
  end

  # Returns the configuration
  def self.configuration
    @configuration ||= Configuration.new
  end

  # Error raised when parsing fails
  class ParseError < StandardError; end

  # Parser class responsible for extracting dates from text
  class Parser
    include DateCalculator
    include PatternMatcher

    # Parse text containing time references and extract both
    # the clean text and the date.
    #
    # @param text [String] the text to parse
    # @return [Hizuke::Result] the parsing result containing text and date
    # @raise [Hizuke::ParseError] if no valid date reference is found
    def self.parse(text)
      new.parse(text)
    end

    # Instance method to parse text
    #
    # @param text [String] the text to parse
    # @return [Hizuke::Result] the parsing result containing text and date
    # @raise [Hizuke::ParseError] if no valid date reference is found
    def parse(text)
      # Check if text is nil or empty
      raise ParseError, 'Input text cannot be nil or empty' if text.nil? || text.empty?

      # Extract time if present
      extracted_time, clean_text = extract_time_references(text)

      # Try different parsing strategies
      result = try_parsing_strategies(clean_text)

      # Return result with the extracted time
      Result.new(result.text, result.date, extracted_time)
    end
  end
end
