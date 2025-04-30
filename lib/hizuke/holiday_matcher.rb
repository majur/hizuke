# frozen_string_literal: true

require_relative 'holidays'

module Hizuke
  # Module for matching holiday patterns in text
  module HolidayMatcher
    include Constants

    # Check for holiday references in the text
    # @param text [String] the text to check
    # @return [Hizuke::Result, nil] the result or nil if no match
    def check_holiday_patterns(text)
      # Convert text to lowercase for easier matching
      text_lower = text.downcase

      # Try to match holiday patterns in text
      match_current_holiday(text_lower) ||
        match_next_holiday(text_lower) ||
        match_last_holiday(text_lower)
    end

    # Match a holiday reference without qualifiers (this year's holiday)
    # @param text [String] the text to check (lowercase)
    # @return [Hizuke::Result, nil] the result or nil if no match
    def match_current_holiday(text)
      Holidays::ALL_HOLIDAYS.each do |holiday_name, calculator|
        # Try to find the holiday name in the text
        next unless text.include?(holiday_name)

        # Extract the holiday from the text
        # Ensure we match the exact holiday name to avoid partial matches
        pattern = Regexp.new("\\b#{Regexp.escape(holiday_name)}\\b", Regexp::IGNORECASE)
        clean_text = text.gsub(pattern, '').strip

        # Calculate the date for this year's holiday
        date = calculator.call(Date.today.year)

        # If the holiday has already passed this year, use next year's date
        date = calculator.call(Date.today.year + 1) if date < Date.today

        return Result.new(clean_text, date)
      end

      nil
    end

    # Match "next [holiday]" pattern
    # @param text [String] the text to check (lowercase)
    # @return [Hizuke::Result, nil] the result or nil if no match
    def match_next_holiday(text)
      match = text.match(/next\s+(.+)/)
      return nil unless match

      potential_holiday = match[1]
      find_holiday_in_potential_match(text, potential_holiday, :next_holiday)
    end

    # Match "last [holiday]" pattern
    # @param text [String] the text to check (lowercase)
    # @return [Hizuke::Result, nil] the result or nil if no match
    def match_last_holiday(text)
      match = text.match(/last\s+(.+)/)
      return nil unless match

      potential_holiday = match[1]
      find_holiday_in_potential_match(text, potential_holiday, :last_holiday)
    end

    private

    # Find a holiday name in the potential match text
    # @param text [String] the original text
    # @param potential_match [String] the potential match text
    # @param holiday_type [Symbol] the type of holiday (:next_holiday or :last_holiday)
    # @return [Hizuke::Result, nil] the result or nil if no match
    def find_holiday_in_potential_match(text, potential_match, holiday_type)
      Holidays::ALL_HOLIDAYS.each do |holiday_name, calculator|
        next unless potential_match.include?(holiday_name)

        # Process the match based on the holiday type
        return process_next_holiday(text, holiday_name, calculator) if holiday_type == :next_holiday

        return process_last_holiday(text, holiday_name, calculator)
      end
      nil
    end

    # Process a "next holiday" match
    # @param text [String] the original text
    # @param holiday_name [String] the name of the holiday
    # @param calculator [Proc] the calculator for the holiday date
    # @return [Hizuke::Result] the result
    def process_next_holiday(text, holiday_name, calculator)
      # Extract the "next holiday" from the text
      # Remove both "next" and the holiday name from the text
      clean_text = text.gsub(/next\s+#{Regexp.escape(holiday_name)}/, '').strip

      # Calculate the date for this year's holiday
      current_year_date = calculator.call(Date.today.year)

      # Determine if we need to use next year's date
      date = current_year_date > Date.today ? current_year_date : calculator.call(Date.today.year + 1)

      Result.new(clean_text, date)
    end

    # Process a "last holiday" match
    # @param text [String] the original text
    # @param holiday_name [String] the name of the holiday
    # @param calculator [Proc] the calculator for the holiday date
    # @return [Hizuke::Result] the result
    def process_last_holiday(text, holiday_name, calculator)
      # Extract the "last holiday" from the text
      # Remove both "last" and the holiday name from the text
      clean_text = text.gsub(/last\s+#{Regexp.escape(holiday_name)}/, '').strip

      # Calculate the date for this year's holiday
      current_year_date = calculator.call(Date.today.year)

      # Determine if we need to use last year's date
      date = current_year_date < Date.today ? current_year_date : calculator.call(Date.today.year - 1)

      Result.new(clean_text, date)
    end
  end
end
