# frozen_string_literal: true

require "date"
require "time"

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
      if sec == 0
        format("%02d:%02d", hour, min)
      else
        format("%02d:%02d:%02d", hour, min, sec)
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

  # Parser class responsible for extracting dates from text
  class Parser
    # Mapping of day names to their wday values (0-6, Sunday is 0)
    DAYS_OF_WEEK = {
      "monday" => 1,
      "tuesday" => 2,
      "wednesday" => 3,
      "thursday" => 4,
      "friday" => 5,
      "saturday" => 6,
      "sunday" => 0
    }.freeze

    # Date keywords mapping
    DATE_KEYWORDS = {
      "yesterday" => -1,
      "today" => 0,
      "tomorrow" => 1,
      "dayaftertomorrow" => 2,
      "day after tomorrow" => 2,
      "daybeforeyesterday" => -2,
      "day before yesterday" => -2,
      "nextweek" => :next_week,
      "next week" => :next_week,
      "lastweek" => :last_week,
      "last week" => :last_week,
      "nextmonth" => :next_month,
      "next month" => :next_month,
      "lastmonth" => :last_month,
      "last month" => :last_month,
      "nextyear" => :next_year,
      "next year" => :next_year,
      "lastyear" => :last_year,
      "last year" => :last_year,
      "nextquarter" => :next_quarter,
      "next quarter" => :next_quarter,
      "lastquarter" => :last_quarter,
      "last quarter" => :last_quarter,
      "thisweekend" => :this_weekend,
      "this weekend" => :this_weekend,
      "endofweek" => :end_of_week,
      "end of week" => :end_of_week,
      "endofmonth" => :end_of_month,
      "end of month" => :end_of_month,
      "endofyear" => :end_of_year,
      "end of year" => :end_of_year,
      "midweek" => :mid_week,
      "mid week" => :mid_week,
      "midmonth" => :mid_month,
      "mid month" => :mid_month
    }.freeze

    # Regex patterns for dynamic date references
    IN_X_DAYS_PATTERN = /in (\d+) days?/i
    X_DAYS_AGO_PATTERN = /(\d+) days? ago/i
    IN_X_WEEKS_PATTERN = /in (\d+) weeks?/i
    X_WEEKS_AGO_PATTERN = /(\d+) weeks? ago/i
    IN_X_MONTHS_PATTERN = /in (\d+) months?/i
    X_MONTHS_AGO_PATTERN = /(\d+) months? ago/i
    IN_X_YEARS_PATTERN = /in (\d+) years?/i
    X_YEARS_AGO_PATTERN = /(\d+) years? ago/i
    
    # Regex patterns for specific days of the week
    THIS_DAY_PATTERN = /this (monday|tuesday|wednesday|thursday|friday|saturday|sunday)/i
    NEXT_DAY_PATTERN = /next (monday|tuesday|wednesday|thursday|friday|saturday|sunday)/i
    LAST_DAY_PATTERN = /last (monday|tuesday|wednesday|thursday|friday|saturday|sunday)/i

    # Regex patterns for time references
    TIME_PATTERN = /(?:at|@)\s*(\d{1,2})(?::(\d{1,2}))?(?::(\d{1,2}))?\s*(am|pm)?/i
    
    # Regex patterns for word-based time references
    NOON_PATTERN = /at\s+noon/i
    MIDNIGHT_PATTERN = /at\s+midnight/i
    MORNING_PATTERN = /in\s+the\s+morning/i
    EVENING_PATTERN = /in\s+the\s+evening/i
    
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
      raise ParseError, "Input text cannot be nil or empty" if text.nil? || text.empty?

      # Extract time if present
      extracted_time = nil
      clean_text = text

      # Try to match word-based time patterns first
      if match = clean_text.match(NOON_PATTERN)
        extracted_time = TimeOfDay.new(12, 0, 0)
        clean_text = clean_text.gsub(match[0], "").strip
      elsif match = clean_text.match(MIDNIGHT_PATTERN)
        extracted_time = TimeOfDay.new(0, 0, 0)
        clean_text = clean_text.gsub(match[0], "").strip
      elsif match = clean_text.match(MORNING_PATTERN)
        config = Hizuke.configuration
        extracted_time = TimeOfDay.new(config.morning_time[:hour], config.morning_time[:min], 0)
        clean_text = clean_text.gsub(match[0], "").strip
      elsif match = clean_text.match(EVENING_PATTERN)
        config = Hizuke.configuration
        extracted_time = TimeOfDay.new(config.evening_time[:hour], config.evening_time[:min], 0)
        clean_text = clean_text.gsub(match[0], "").strip
      # Then try the numeric time pattern
      elsif time_match = clean_text.match(TIME_PATTERN)
        hour = time_match[1].to_i
        min = time_match[2] ? time_match[2].to_i : 0
        sec = time_match[3] ? time_match[3].to_i : 0
        
        # Adjust for AM/PM
        if time_match[4]&.downcase == "pm" && hour < 12
          hour += 12
        elsif time_match[4]&.downcase == "am" && hour == 12
          hour = 0
        end
        
        extracted_time = TimeOfDay.new(hour, min, sec)
        
        # Remove the time expression from the text
        clean_text = clean_text.gsub(time_match[0], "").strip
      end

      # Check for dynamic patterns first (in X days, X days ago)
      result = check_dynamic_patterns(clean_text)
      if result
        return Result.new(result.text, result.date, extracted_time)
      end

      # Check for day of week patterns (this Monday, next Tuesday, etc.)
      result = check_day_of_week_patterns(clean_text)
      if result
        return Result.new(result.text, result.date, extracted_time)
      end

      # Try to find compound date expressions (like "next week")
      compound_matches = {}
      
      DATE_KEYWORDS.keys.select { |k| k.include?(" ") }.each do |compound_key|
        if clean_text.downcase.include?(compound_key)
          start_idx = clean_text.downcase.index(compound_key)
          end_idx = start_idx + compound_key.length - 1
          compound_matches[compound_key] = [start_idx, end_idx]
        end
      end

      # If we found compound matches, handle them specially
      unless compound_matches.empty?
        # Use the first match (in case there are multiple)
        match_key, indices = compound_matches.min_by { |_, v| v[0] }
        
        # Calculate date based on the keyword
        date_value = DATE_KEYWORDS[match_key]
        date = calculate_date(date_value)
        
        # Remove the date expression from the text
        final_text = clean_text.dup
        final_text.slice!(indices[0]..indices[1])
        final_text = final_text.strip
        
        return Result.new(final_text, date, extracted_time)
      end

      # Split the text into words (for single-word date references)
      words = clean_text.split

      # Find the first date keyword
      date_word_index = nil
      date_value = nil

      words.each_with_index do |word, index|
        clean_word = word.downcase.gsub(/[^a-z]/, '')
        if DATE_KEYWORDS.key?(clean_word)
          date_word_index = index
          date_value = DATE_KEYWORDS[clean_word]
          break
        end
      end

      if date_word_index.nil?
        raise ParseError, "No valid date reference found in '#{clean_text}'"
      end

      # Calculate the date based on the keyword
      date = calculate_date(date_value)

      # Create the clean text by removing the date keyword
      clean_words = words.dup
      clean_words.delete_at(date_word_index)
      final_text = clean_words.join(" ").strip

      Result.new(final_text, date, extracted_time)
    end

    private

    # Check for day of week patterns (this Monday, next Tuesday, last Friday, etc.)
    def check_day_of_week_patterns(text)
      # Check for "this [day]" pattern
      if (match = text.match(THIS_DAY_PATTERN))
        day_name = match[1].downcase
        day_value = DAYS_OF_WEEK[day_name]
        date = calculate_this_day(day_value)
        clean_text = text.gsub(match[0], "").strip
        return Result.new(clean_text, date)
      end

      # Check for "next [day]" pattern
      if (match = text.match(NEXT_DAY_PATTERN))
        day_name = match[1].downcase
        day_value = DAYS_OF_WEEK[day_name]
        date = calculate_next_day(day_value)
        clean_text = text.gsub(match[0], "").strip
        return Result.new(clean_text, date)
      end

      # Check for "last [day]" pattern
      if (match = text.match(LAST_DAY_PATTERN))
        day_name = match[1].downcase
        day_value = DAYS_OF_WEEK[day_name]
        date = calculate_last_day(day_value)
        clean_text = text.gsub(match[0], "").strip
        return Result.new(clean_text, date)
      end

      nil
    end

    # Check for dynamic date patterns like "in X days" or "X days ago"
    def check_dynamic_patterns(text)
      # Check for "in X days" pattern
      if (match = text.match(IN_X_DAYS_PATTERN))
        days = match[1].to_i
        date = Date.today + days
        clean_text = text.gsub(match[0], "").strip
        return Result.new(clean_text, date)
      end

      # Check for "X days ago" pattern
      if (match = text.match(X_DAYS_AGO_PATTERN))
        days = match[1].to_i
        date = Date.today - days
        clean_text = text.gsub(match[0], "").strip
        return Result.new(clean_text, date)
      end

      # Check for "in X weeks" pattern
      if (match = text.match(IN_X_WEEKS_PATTERN))
        weeks = match[1].to_i
        date = Date.today + (weeks * 7)
        clean_text = text.gsub(match[0], "").strip
        return Result.new(clean_text, date)
      end

      # Check for "X weeks ago" pattern
      if (match = text.match(X_WEEKS_AGO_PATTERN))
        weeks = match[1].to_i
        date = Date.today - (weeks * 7)
        clean_text = text.gsub(match[0], "").strip
        return Result.new(clean_text, date)
      end

      # Check for "in X months" pattern
      if (match = text.match(IN_X_MONTHS_PATTERN))
        months = match[1].to_i
        date = Date.today >> months
        clean_text = text.gsub(match[0], "").strip
        return Result.new(clean_text, date)
      end

      # Check for "X months ago" pattern
      if (match = text.match(X_MONTHS_AGO_PATTERN))
        months = match[1].to_i
        date = Date.today << months
        clean_text = text.gsub(match[0], "").strip
        return Result.new(clean_text, date)
      end

      # Check for "in X years" pattern
      if (match = text.match(IN_X_YEARS_PATTERN))
        years = match[1].to_i
        date = Date.new(Date.today.year + years, Date.today.month, Date.today.day)
        clean_text = text.gsub(match[0], "").strip
        return Result.new(clean_text, date)
      end

      # Check for "X years ago" pattern
      if (match = text.match(X_YEARS_AGO_PATTERN))
        years = match[1].to_i
        date = Date.new(Date.today.year - years, Date.today.month, Date.today.day)
        clean_text = text.gsub(match[0], "").strip
        return Result.new(clean_text, date)
      end

      nil
    end

    # Calculate date for "this [day]" - the current/upcoming day in this week
    def calculate_this_day(target_wday)
      today = Date.today
      today_wday = today.wday
      
      # Calculate days until the target day in this week
      days_diff = (target_wday - today_wday) % 7
      
      # If it's the same day, return today's date
      if days_diff == 0
        return today
      end
      
      # Return the date of the next occurrence in this week
      today + days_diff
    end

    # Calculate date for "next [day]" - the day in next week
    def calculate_next_day(target_wday)
      today = Date.today
      today_wday = today.wday
      
      # Calculate days until the next occurrence
      days_until_target = (target_wday - today_wday) % 7
      
      # If today is the target day or the target day is earlier in the week,
      # we want the day next week, so add 7 days
      if days_until_target == 0 || target_wday < today_wday
        days_until_target += 7
      end
      
      today + days_until_target
    end

    # Calculate date for "last [day]" - the day in previous week
    def calculate_last_day(target_wday)
      today = Date.today
      today_wday = today.wday
      
      # Calculate days since the last occurrence
      days_since_target = (today_wday - target_wday) % 7
      
      # If today is the target day or the target day is later in the week,
      # we want the day last week, so add 7 days
      if days_since_target == 0 || target_wday > today_wday
        days_since_target += 7
      end
      
      today - days_since_target
    end

    # Calculate the date based on the keyword value
    def calculate_date(date_value)
      if date_value.is_a?(Integer)
        Date.today + date_value
      elsif date_value == :next_week
        # Find next Monday
        days_until_monday = (1 - Date.today.wday) % 7
        # If today is Monday, we want next Monday, not today
        days_until_monday = 7 if days_until_monday == 0
        Date.today + days_until_monday
      elsif date_value == :last_week
        # Find last Monday
        days_since_monday = (Date.today.wday - 1) % 7
        # If today is Monday, we want last Monday, not today
        days_since_monday = 7 if days_since_monday == 0
        Date.today - days_since_monday - 7
      elsif date_value == :next_month
        # Return the first day of the next month
        next_month = Date.today >> 1
        Date.new(next_month.year, next_month.month, 1)
      elsif date_value == :last_month
        # Return the first day of the previous month
        prev_month = Date.today << 1
        Date.new(prev_month.year, prev_month.month, 1)
      elsif date_value == :next_year
        # Return the first day of the next year
        next_year = Date.today.year + 1
        Date.new(next_year, 1, 1)
      elsif date_value == :last_year
        # Return the first day of the last year
        last_year = Date.today.year - 1
        Date.new(last_year, 1, 1)
      elsif date_value == :next_quarter
        # Return the first day of the next quarter
        today = Date.today
        current_month = today.month
        
        # Determine the start month of the next quarter
        next_quarter_month = case
                             when current_month <= 3
                               4  # Q2 starts in April
                             when current_month <= 6
                               7  # Q3 starts in July
                             when current_month <= 9
                               10 # Q4 starts in October
                             else
                               1  # Q1 of next year starts in January
                             end
        
        # If the next quarter is in the next year, increment the year
        next_quarter_year = today.year
        next_quarter_year += 1 if current_month > 9
        
        Date.new(next_quarter_year, next_quarter_month, 1)
      elsif date_value == :last_quarter
        # Return the first day of the last quarter
        today = Date.today
        current_month = today.month
        
        # Determine the start month of the last quarter
        last_quarter_month = case
                             when current_month <= 3
                               10 # Q4 of last year starts in October
                             when current_month <= 6
                               1  # Q1 starts in January
                             when current_month <= 9
                               4  # Q2 starts in April
                             else
                               7  # Q3 starts in July
                             end
        
        # If the last quarter is in the previous year, decrement the year
        last_quarter_year = today.year
        last_quarter_year -= 1 if current_month <= 3
        
        Date.new(last_quarter_year, last_quarter_month, 1)
      elsif date_value == :this_weekend
        # Calculate days until Saturday
        days_until_saturday = (6 - Date.today.wday) % 7
        # If today is Saturday or Sunday, we're already on the weekend
        days_until_saturday = 0 if days_until_saturday == 0 || days_until_saturday == 6
        Date.today + days_until_saturday
      elsif date_value == :end_of_week
        # Calculate days until Sunday (end of week)
        days_until_sunday = (0 - Date.today.wday) % 7
        # If today is Sunday, we're already at the end of the week
        days_until_sunday = 0 if days_until_sunday == 0
        Date.today + days_until_sunday
      elsif date_value == :end_of_month
        # Return the last day of the current month
        # Get the first day of next month
        next_month = Date.today >> 1
        first_day_next_month = Date.new(next_month.year, next_month.month, 1)
        # Subtract one day to get the last day of current month
        first_day_next_month - 1
      elsif date_value == :end_of_year
        # Return the last day of the current year (December 31)
        Date.new(Date.today.year, 12, 31)
      elsif date_value == :mid_week
        # Return Wednesday of the current week
        # Calculate days until/since Wednesday (3)
        today_wday = Date.today.wday
        target_wday = 3 # Wednesday
        days_diff = (target_wday - today_wday) % 7
        # If the difference is more than 3, then Wednesday has passed this week
        # So we need to go back to Wednesday
        days_diff = days_diff - 7 if days_diff > 3
        Date.today + days_diff
      elsif date_value == :mid_month
        # Return the 15th day of the current month
        Date.new(Date.today.year, Date.today.month, 15)
      end
    end
  end
end 