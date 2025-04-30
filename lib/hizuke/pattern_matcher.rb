# frozen_string_literal: true

module Hizuke
  # Module responsible for pattern matching in text
  module PatternMatcher
    include Constants

    # Extract time references from the text
    # @param text [String] the original text
    # @return [Array] an array containing the extracted time and clean text
    def extract_time_references(text)
      clean_text = text
      extracted_time = nil

      # Try to match word-based time patterns first
      if (match = clean_text.match(NOON_PATTERN))
        extracted_time = TimeOfDay.new(12, 0, 0)
        clean_text = clean_text.gsub(match[0], '').strip
      elsif (match = clean_text.match(MIDNIGHT_PATTERN))
        extracted_time = TimeOfDay.new(0, 0, 0)
        clean_text = clean_text.gsub(match[0], '').strip
      elsif (match = clean_text.match(MORNING_PATTERN))
        config = Hizuke.configuration
        extracted_time = TimeOfDay.new(config.morning_time[:hour], config.morning_time[:min], 0)
        clean_text = clean_text.gsub(match[0], '').strip
      elsif (match = clean_text.match(EVENING_PATTERN))
        config = Hizuke.configuration
        extracted_time = TimeOfDay.new(config.evening_time[:hour], config.evening_time[:min], 0)
        clean_text = clean_text.gsub(match[0], '').strip
      # Then try the numeric time pattern
      elsif (time_match = clean_text.match(TIME_PATTERN))
        extracted_time = process_time_match(time_match)
        # Remove the time expression from the text
        clean_text = clean_text.gsub(time_match[0], '').strip
      end

      [extracted_time, clean_text]
    end

    # Process a time match and create a TimeOfDay object
    # @param time_match [MatchData] the regex match data
    # @return [TimeOfDay] the created time of day object
    def process_time_match(time_match)
      hour = time_match[1].to_i
      min = time_match[2] ? time_match[2].to_i : 0
      sec = time_match[3] ? time_match[3].to_i : 0

      # Adjust for AM/PM
      if time_match[4]&.downcase == 'pm' && hour < 12
        hour += 12
      elsif time_match[4]&.downcase == 'am' && hour == 12
        hour = 0
      end

      TimeOfDay.new(hour, min, sec)
    end

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

      DATE_KEYWORDS.keys.select { |k| k.include?(' ') }.each do |compound_key|
        next unless clean_text.downcase.include?(compound_key)

        start_idx = clean_text.downcase.index(compound_key)
        end_idx = start_idx + compound_key.length - 1
        compound_matches[compound_key] = [start_idx, end_idx]
      end

      compound_matches
    end

    # Check for single-word date references
    # @param clean_text [String] the text to check
    # @return [Hizuke::Result] the parsing result
    # @raise [Hizuke::ParseError] if no valid date reference is found
    def check_single_word_date_references(clean_text)
      # Split the text into words
      words = clean_text.split

      # Find the first date keyword
      date_word_index = nil
      date_value = nil

      words.each_with_index do |word, index|
        clean_word = word.downcase.gsub(/[^a-z]/, '')
        next unless DATE_KEYWORDS.key?(clean_word)

        date_word_index = index
        date_value = DATE_KEYWORDS[clean_word]
        break
      end

      raise ParseError, "No valid date reference found in '#{clean_text}'" if date_word_index.nil?

      # Calculate the date based on the keyword
      date = calculate_date(date_value)

      # Create the clean text by removing the date keyword
      clean_words = words.dup
      clean_words.delete_at(date_word_index)
      final_text = clean_words.join(' ').strip

      Result.new(final_text, date)
    end

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
      # Check for "in X days" pattern
      if (match = text.match(IN_X_DAYS_PATTERN))
        days = match[1].to_i
        date = Date.today + days
        clean_text = text.gsub(match[0], '').strip
        return Result.new(clean_text, date)
      end

      # Check for "X days ago" pattern
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
      # Check for "in X weeks" pattern
      if (match = text.match(IN_X_WEEKS_PATTERN))
        weeks = match[1].to_i
        date = Date.today + (weeks * 7)
        clean_text = text.gsub(match[0], '').strip
        return Result.new(clean_text, date)
      end

      # Check for "X weeks ago" pattern
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
      # Check for "in X months" pattern
      if (match = text.match(IN_X_MONTHS_PATTERN))
        months = match[1].to_i
        date = Date.today >> months
        clean_text = text.gsub(match[0], '').strip
        return Result.new(clean_text, date)
      end

      # Check for "X months ago" pattern
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
      # Check for "in X years" pattern
      if (match = text.match(IN_X_YEARS_PATTERN))
        years = match[1].to_i
        date = Date.new(Date.today.year + years, Date.today.month, Date.today.day)
        clean_text = text.gsub(match[0], '').strip
        return Result.new(clean_text, date)
      end

      # Check for "X years ago" pattern
      if (match = text.match(X_YEARS_AGO_PATTERN))
        years = match[1].to_i
        date = Date.new(Date.today.year - years, Date.today.month, Date.today.day)
        clean_text = text.gsub(match[0], '').strip
        return Result.new(clean_text, date)
      end

      nil
    end
  end
end
