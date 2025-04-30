# frozen_string_literal: true

module Hizuke
  # Module for working with time patterns
  module TimePatternMatcher
    include Constants

    # Extract time references from the text
    # @param text [String] the original text
    # @return [Array] an array containing the extracted time and clean text
    def extract_time_references(text)
      clean_text = text
      extracted_time = nil

      # Try each type of time pattern
      result = try_word_time_patterns(clean_text) ||
               try_numeric_time_pattern(clean_text)

      extracted_time, clean_text = result if result

      [extracted_time, clean_text]
    end

    # Try to match word-based time patterns
    # @param text [String] the original text
    # @return [Array, nil] an array containing the extracted time and clean text, or nil if no match
    def try_word_time_patterns(text)
      match_noon_pattern(text) ||
        match_midnight_pattern(text) ||
        match_morning_pattern(text) ||
        match_evening_pattern(text)
    end

    # Match the noon pattern in the text
    # @param text [String] the original text
    # @return [Array, nil] an array containing the extracted time and clean text, or nil if no match
    def match_noon_pattern(text)
      match_and_process(text, NOON_PATTERN) do
        TimeOfDay.new(12, 0, 0)
      end
    end

    # Match the midnight pattern in the text
    # @param text [String] the original text
    # @return [Array, nil] an array containing the extracted time and clean text, or nil if no match
    def match_midnight_pattern(text)
      match_and_process(text, MIDNIGHT_PATTERN) do
        TimeOfDay.new(0, 0, 0)
      end
    end

    # Match the morning pattern in the text
    # @param text [String] the original text
    # @return [Array, nil] an array containing the extracted time and clean text, or nil if no match
    def match_morning_pattern(text)
      match_and_process(text, MORNING_PATTERN) do
        config = Hizuke.configuration
        TimeOfDay.new(config.morning_time[:hour], config.morning_time[:min], 0)
      end
    end

    # Match the evening pattern in the text
    # @param text [String] the original text
    # @return [Array, nil] an array containing the extracted time and clean text, or nil if no match
    def match_evening_pattern(text)
      match_and_process(text, EVENING_PATTERN) do
        config = Hizuke.configuration
        TimeOfDay.new(config.evening_time[:hour], config.evening_time[:min], 0)
      end
    end

    # Match a pattern and process it with the given block
    # @param text [String] the original text
    # @param pattern [Regexp] the pattern to match
    # @yield a block that creates a TimeOfDay object
    # @return [Array, nil] an array containing the extracted time and clean text, or nil if no match
    def match_and_process(text, pattern)
      return nil unless (match = text.match(pattern))

      time = yield
      clean_text = text.gsub(match[0], '').strip
      [time, clean_text]
    end

    # Try to match numeric time pattern
    # @param text [String] the original text
    # @return [Array, nil] an array containing the extracted time and clean text, or nil if no match
    def try_numeric_time_pattern(text)
      if (time_match = text.match(TIME_PATTERN))
        extracted_time = process_time_match(time_match)
        # Remove the time expression from the text
        clean_text = text.gsub(time_match[0], '').strip
        return [extracted_time, clean_text]
      end

      nil
    end

    # Process a time match and create a TimeOfDay object
    # @param time_match [MatchData] the regex match data
    # @return [TimeOfDay] the created time of day object
    def process_time_match(time_match)
      hour = parse_hour(time_match[1])
      min = parse_minute(time_match[2])
      sec = parse_second(time_match[3])

      # Adjust for AM/PM
      hour = adjust_hour_for_meridiem(hour, time_match[4])

      TimeOfDay.new(hour, min, sec)
    end

    # Parse hour from match data
    # @param hour_str [String, nil] the hour part of the match
    # @return [Integer] the parsed hour
    def parse_hour(hour_str)
      hour_str.to_i
    end

    # Parse minute from match data
    # @param min_str [String, nil] the minute part of the match
    # @return [Integer] the parsed minute
    def parse_minute(min_str)
      min_str ? min_str.to_i : 0
    end

    # Parse second from match data
    # @param sec_str [String, nil] the second part of the match
    # @return [Integer] the parsed second
    def parse_second(sec_str)
      sec_str ? sec_str.to_i : 0
    end

    # Adjust hour based on AM/PM designation
    # @param hour [Integer] the hour to adjust
    # @param meridiem [String, nil] the meridiem designation (am/pm)
    # @return [Integer] the adjusted hour
    def adjust_hour_for_meridiem(hour, meridiem)
      if meridiem&.downcase == 'pm' && hour < 12
        hour + 12
      elsif meridiem&.downcase == 'am' && hour == 12
        0
      else
        hour
      end
    end
  end

  # Module for handling day of week patterns
  module DayOfWeekPatternMatcher
    include Constants

    # Check for day of week patterns (this Monday, next Tuesday, last Friday, etc.)
    # @param text [String] the text to check
    # @return [Hizuke::Result, nil] the result or nil if no match
    def check_day_of_week_patterns(text)
      # Try each day of week pattern
      check_this_day_pattern(text) ||
        check_next_day_pattern(text) ||
        check_last_day_pattern(text)
    end

    # Check for "this [day]" pattern
    # @param text [String] the text to check
    # @return [Hizuke::Result, nil] the result or nil if no match
    def check_this_day_pattern(text)
      if (match = text.match(THIS_DAY_PATTERN))
        day_name = match[1].downcase
        day_value = DAYS_OF_WEEK[day_name]
        date = calculate_this_day(day_value)
        clean_text = text.gsub(match[0], '').strip
        return Result.new(clean_text, date)
      end

      nil
    end

    # Check for "next [day]" pattern
    # @param text [String] the text to check
    # @return [Hizuke::Result, nil] the result or nil if no match
    def check_next_day_pattern(text)
      if (match = text.match(NEXT_DAY_PATTERN))
        day_name = match[1].downcase
        day_value = DAYS_OF_WEEK[day_name]
        date = calculate_next_day(day_value)
        clean_text = text.gsub(match[0], '').strip
        return Result.new(clean_text, date)
      end

      nil
    end

    # Check for "last [day]" pattern
    # @param text [String] the text to check
    # @return [Hizuke::Result, nil] the result or nil if no match
    def check_last_day_pattern(text)
      if (match = text.match(LAST_DAY_PATTERN))
        day_name = match[1].downcase
        day_value = DAYS_OF_WEEK[day_name]
        date = calculate_last_day(day_value)
        clean_text = text.gsub(match[0], '').strip
        return Result.new(clean_text, date)
      end

      nil
    end
  end

  # Module for dynamic date patterns (in X days, X days ago, etc.)
  module DynamicPatternMatcher
    include Constants

    # Check for dynamic date patterns like "in X days" or "X days ago"
    # @param text [String] the text to check
    # @return [Hizuke::Result, nil] the result or nil if no match
    def check_dynamic_patterns(text)
      # Try each pattern type
      check_days_patterns(text) ||
        check_weeks_patterns(text) ||
        check_months_patterns(text) ||
        check_years_patterns(text)
    end

    # Check for days-related patterns
    # @param text [String] the text to check
    # @return [Hizuke::Result, nil] the result or nil if no match
    def check_days_patterns(text)
      check_in_x_days_pattern(text) || check_x_days_ago_pattern(text)
    end

    # Check for "in X days" pattern
    # @param text [String] the text to check
    # @return [Hizuke::Result, nil] the result or nil if no match
    def check_in_x_days_pattern(text)
      if (match = text.match(IN_X_DAYS_PATTERN))
        days = match[1].to_i
        date = Date.today + days
        clean_text = text.gsub(match[0], '').strip
        return Result.new(clean_text, date)
      end
      nil
    end

    # Check for "X days ago" pattern
    # @param text [String] the text to check
    # @return [Hizuke::Result, nil] the result or nil if no match
    def check_x_days_ago_pattern(text)
      if (match = text.match(X_DAYS_AGO_PATTERN))
        days = match[1].to_i
        date = Date.today - days
        clean_text = text.gsub(match[0], '').strip
        return Result.new(clean_text, date)
      end
      nil
    end

    # Check for weeks-related patterns
    # @param text [String] the text to check
    # @return [Hizuke::Result, nil] the result or nil if no match
    def check_weeks_patterns(text)
      check_in_x_weeks_pattern(text) || check_x_weeks_ago_pattern(text)
    end

    # Check for "in X weeks" pattern
    # @param text [String] the text to check
    # @return [Hizuke::Result, nil] the result or nil if no match
    def check_in_x_weeks_pattern(text)
      if (match = text.match(IN_X_WEEKS_PATTERN))
        weeks = match[1].to_i
        date = Date.today + (weeks * 7)
        clean_text = text.gsub(match[0], '').strip
        return Result.new(clean_text, date)
      end
      nil
    end

    # Check for "X weeks ago" pattern
    # @param text [String] the text to check
    # @return [Hizuke::Result, nil] the result or nil if no match
    def check_x_weeks_ago_pattern(text)
      if (match = text.match(X_WEEKS_AGO_PATTERN))
        weeks = match[1].to_i
        date = Date.today - (weeks * 7)
        clean_text = text.gsub(match[0], '').strip
        return Result.new(clean_text, date)
      end
      nil
    end

    # Check for months-related patterns
    # @param text [String] the text to check
    # @return [Hizuke::Result, nil] the result or nil if no match
    def check_months_patterns(text)
      check_in_x_months_pattern(text) || check_x_months_ago_pattern(text)
    end

    # Check for "in X months" pattern
    # @param text [String] the text to check
    # @return [Hizuke::Result, nil] the result or nil if no match
    def check_in_x_months_pattern(text)
      if (match = text.match(IN_X_MONTHS_PATTERN))
        months = match[1].to_i
        date = Date.today >> months
        clean_text = text.gsub(match[0], '').strip
        return Result.new(clean_text, date)
      end
      nil
    end

    # Check for "X months ago" pattern
    # @param text [String] the text to check
    # @return [Hizuke::Result, nil] the result or nil if no match
    def check_x_months_ago_pattern(text)
      if (match = text.match(X_MONTHS_AGO_PATTERN))
        months = match[1].to_i
        date = Date.today << months
        clean_text = text.gsub(match[0], '').strip
        return Result.new(clean_text, date)
      end
      nil
    end

    # Check for years-related patterns
    # @param text [String] the text to check
    # @return [Hizuke::Result, nil] the result or nil if no match
    def check_years_patterns(text)
      check_in_x_years_pattern(text) || check_x_years_ago_pattern(text)
    end

    # Check for "in X years" pattern
    # @param text [String] the text to check
    # @return [Hizuke::Result, nil] the result or nil if no match
    def check_in_x_years_pattern(text)
      if (match = text.match(IN_X_YEARS_PATTERN))
        years = match[1].to_i
        date = Date.new(Date.today.year + years, Date.today.month, Date.today.day)
        clean_text = text.gsub(match[0], '').strip
        return Result.new(clean_text, date)
      end
      nil
    end

    # Check for "X years ago" pattern
    # @param text [String] the text to check
    # @return [Hizuke::Result, nil] the result or nil if no match
    def check_x_years_ago_pattern(text)
      if (match = text.match(X_YEARS_AGO_PATTERN))
        years = match[1].to_i
        date = Date.new(Date.today.year - years, Date.today.month, Date.today.day)
        clean_text = text.gsub(match[0], '').strip
        return Result.new(clean_text, date)
      end
      nil
    end
  end

  # Module for compound date expressions and keywords
  module DateKeywordMatcher
    include Constants

    # Try different parsing strategies to find a date reference
    # @param clean_text [String] the text without time references
    # @return [Hizuke::Result] the parsing result
    def try_parsing_strategies(clean_text)
      # Check for dynamic patterns first (in X days, X days ago)
      result = check_dynamic_patterns(clean_text)
      return result if result

      # Check for day of week patterns (this Monday, next Tuesday, etc.)
      result = check_day_of_week_patterns(clean_text)
      return result if result

      # Try to find compound date expressions (like "next week")
      result = check_compound_date_expressions(clean_text)
      return result if result

      # Try to find single-word date references
      check_single_word_date_references(clean_text)
    end

    # Check for compound date expressions like "next week"
    # @param clean_text [String] the text to check
    # @return [Hizuke::Result, nil] the result or nil if no match
    def check_compound_date_expressions(clean_text)
      compound_matches = find_compound_matches(clean_text)

      # If we found compound matches, handle them specially
      return nil if compound_matches.empty?

      # Use the first match (in case there are multiple)
      match_key, indices = compound_matches.min_by { |_, v| v[0] }

      process_compound_match(clean_text, match_key, indices)
    end

    # Process a compound date expression match
    # @param clean_text [String] the text to check
    # @param match_key [String] the matched keyword
    # @param indices [Array<Integer>] the start and end indices of the match
    # @return [Hizuke::Result] the result
    def process_compound_match(clean_text, match_key, indices)
      # Calculate date based on the keyword
      date_value = DATE_KEYWORDS[match_key]
      date = calculate_date(date_value)

      # Remove the date expression from the text
      final_text = clean_text.dup
      final_text.slice!(indices[0]..indices[1])

      Result.new(final_text.strip, date)
    end

    # Find compound date expressions in the text
    # @param clean_text [String] the text to check
    # @return [Hash] a hash of matches and their indices
    def find_compound_matches(clean_text)
      compound_matches = {}

      find_compound_keywords.each do |compound_key|
        next unless clean_text.downcase.include?(compound_key)

        start_idx = clean_text.downcase.index(compound_key)
        end_idx = start_idx + compound_key.length - 1
        compound_matches[compound_key] = [start_idx, end_idx]
      end

      compound_matches
    end

    # Find compound keywords (containing spaces)
    # @return [Array<String>] array of compound keywords
    def find_compound_keywords
      DATE_KEYWORDS.keys.select { |k| k.include?(' ') }
    end

    # Check for single-word date references
    # @param clean_text [String] the text to check
    # @return [Hizuke::Result] the parsing result
    # @raise [Hizuke::ParseError] if no valid date reference is found
    def check_single_word_date_references(clean_text)
      # Split the text into words
      words = clean_text.split

      # Find the matching date keyword
      date_match = find_date_keyword_match(words)

      # Calculate the date based on the keyword
      date = calculate_date(date_match[:value])

      # Create the clean text by removing the date keyword
      final_text = remove_date_keyword_from_text(words, date_match[:index])

      Result.new(final_text, date)
    end

    # Find a date keyword match in the words
    # @param words [Array<String>] the words to check
    # @return [Hash] a hash with the index and value of the match
    # @raise [Hizuke::ParseError] if no valid date reference is found
    def find_date_keyword_match(words)
      words.each_with_index do |word, index|
        clean_word = word.downcase.gsub(/[^a-z]/, '')
        next unless DATE_KEYWORDS.key?(clean_word)

        return { index: index, value: DATE_KEYWORDS[clean_word] }
      end

      raise ParseError, "No valid date reference found in '#{words.join(' ')}'"
    end

    # Remove the date keyword from the text
    # @param words [Array<String>] the words array
    # @param index [Integer] the index of the keyword to remove
    # @return [String] the text without the keyword
    def remove_date_keyword_from_text(words, index)
      clean_words = words.dup
      clean_words.delete_at(index)
      clean_words.join(' ').strip
    end
  end

  # Module for handling pattern matching
  module PatternMatcher
    include TimePatternMatcher
    include DayOfWeekPatternMatcher
    include DynamicPatternMatcher
    include DateKeywordMatcher
    include HolidayMatcher

    # Try different parsing strategies to find a date in the text
    # @param text [String] the text to parse
    # @return [Hizuke::Result] the result with date and clean text
    def try_parsing_strategies(clean_text)
      # Check for holiday patterns first
      result = check_holiday_patterns(clean_text)
      return result if result

      # Then check for dynamic patterns (in X days, X days ago)
      result = check_dynamic_patterns(clean_text)
      return result if result

      # Then check day of week patterns (this Monday, next Tuesday, last Friday)
      result = check_day_of_week_patterns(clean_text)
      return result if result

      # Then check compound date expressions (day after tomorrow, end of month)
      result = check_compound_date_expressions(clean_text)
      return result if result

      # Finally try single words (today, tomorrow, yesterday)
      result = check_single_word_date_references(clean_text)
      return result if result

      # Default to today if no explicit date reference is found
      Result.new(clean_text, Date.today)
    end
  end
end
