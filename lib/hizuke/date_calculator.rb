# frozen_string_literal: true

module Hizuke
  # Module responsible for date calculations
  module DateCalculator
    # Calculate date for "this [day]" - the current/upcoming day in this week
    # @param target_wday [Integer] the target day of week (0-6, Sunday is 0)
    # @return [Date] the calculated date
    def calculate_this_day(target_wday)
      today = Date.today
      today_wday = today.wday

      # Calculate days until the target day in this week
      days_diff = (target_wday - today_wday) % 7

      # If it's the same day, return today's date
      return today if days_diff.zero?

      # Return the date of the next occurrence in this week
      today + days_diff
    end

    # Calculate date for "next [day]" - the day in next week
    # @param target_wday [Integer] the target day of week (0-6, Sunday is 0)
    # @return [Date] the calculated date
    def calculate_next_day(target_wday)
      today = Date.today
      today_wday = today.wday

      # Calculate days until the next occurrence
      days_until_target = (target_wday - today_wday) % 7

      # If today is the target day or the target day is earlier in the week,
      # we want the day next week, so add 7 days
      days_until_target += 7 if days_until_target.zero? || target_wday < today_wday

      today + days_until_target
    end

    # Calculate date for "last [day]" - the day in previous week
    # @param target_wday [Integer] the target day of week (0-6, Sunday is 0)
    # @return [Date] the calculated date
    def calculate_last_day(target_wday)
      today = Date.today
      today_wday = today.wday

      # Calculate days since the last occurrence
      days_since_target = (today_wday - target_wday) % 7

      # If today is the target day or the target day is later in the week,
      # we want the day last week, so add 7 days
      days_since_target += 7 if days_since_target.zero? || target_wday > today_wday

      today - days_since_target
    end

    # Calculate the date based on the keyword value
    # @param date_value [Symbol, Integer] the date value to calculate from
    # @return [Date] the calculated date
    def calculate_date(date_value)
      case date_value
      when Integer
        Date.today + date_value
      when :next_week, :last_week
        calculate_week_date(date_value)
      when :next_month, :last_month
        calculate_month_date(date_value)
      when :next_year, :last_year
        calculate_year_date(date_value)
      when :next_quarter, :last_quarter
        calculate_quarter_date(date_value)
      when :this_weekend, :end_of_week, :end_of_month, :end_of_year
        calculate_period_end_date(date_value)
      when :mid_week, :mid_month
        calculate_period_mid_date(date_value)
      end
    end

    # Calculate week-related dates
    # @param date_value [Symbol] the date keyword (:next_week or :last_week)
    # @return [Date] the calculated date
    def calculate_week_date(date_value)
      case date_value
      when :next_week
        # Find next Monday
        days_until_monday = (1 - Date.today.wday) % 7
        # If today is Monday, we want next Monday, not today
        days_until_monday = 7 if days_until_monday.zero?
        Date.today + days_until_monday
      when :last_week
        # Find last Monday
        days_since_monday = (Date.today.wday - 1) % 7
        # If today is Monday, we want last Monday, not today
        days_since_monday = 7 if days_since_monday.zero?
        Date.today - days_since_monday - 7
      end
    end

    # Calculate month-related dates
    # @param date_value [Symbol] the date keyword (:next_month or :last_month)
    # @return [Date] the calculated date
    def calculate_month_date(date_value)
      case date_value
      when :next_month
        # Return the first day of the next month
        next_month = Date.today >> 1
        Date.new(next_month.year, next_month.month, 1)
      when :last_month
        # Return the first day of the previous month
        prev_month = Date.today << 1
        Date.new(prev_month.year, prev_month.month, 1)
      end
    end

    # Calculate year-related dates
    # @param date_value [Symbol] the date keyword (:next_year or :last_year)
    # @return [Date] the calculated date
    def calculate_year_date(date_value)
      case date_value
      when :next_year
        # Return the first day of the next year
        next_year = Date.today.year + 1
        Date.new(next_year, 1, 1)
      when :last_year
        # Return the first day of the last year
        last_year = Date.today.year - 1
        Date.new(last_year, 1, 1)
      end
    end

    # Calculate quarter-related dates
    # @param date_value [Symbol] the date keyword (:next_quarter or :last_quarter)
    # @return [Date] the calculated date
    def calculate_quarter_date(date_value)
      case date_value
      when :next_quarter
        calculate_next_quarter_date
      when :last_quarter
        calculate_last_quarter_date
      end
    end

    # Calculate the date for next quarter
    # @return [Date] the first day of the next quarter
    def calculate_next_quarter_date
      today = Date.today
      current_month = today.month

      # Determine the start month of the next quarter
      next_quarter_month = if current_month <= 3
                             4  # Q2 starts in April
                           elsif current_month <= 6
                             7  # Q3 starts in July
                           elsif current_month <= 9
                             10 # Q4 starts in October
                           else
                             1  # Q1 of next year starts in January
                           end

      # If the next quarter is in the next year, increment the year
      next_quarter_year = today.year
      next_quarter_year += 1 if current_month > 9

      Date.new(next_quarter_year, next_quarter_month, 1)
    end

    # Calculate the date for last quarter
    # @return [Date] the first day of the last quarter
    def calculate_last_quarter_date
      today = Date.today
      current_month = today.month

      # Determine the start month of the last quarter
      last_quarter_month = if current_month <= 3
                             10 # Q4 of last year starts in October
                           elsif current_month <= 6
                             1  # Q1 starts in January
                           elsif current_month <= 9
                             4  # Q2 starts in April
                           else
                             7  # Q3 starts in July
                           end

      # If the last quarter is in the previous year, decrement the year
      last_quarter_year = today.year
      last_quarter_year -= 1 if current_month <= 3

      Date.new(last_quarter_year, last_quarter_month, 1)
    end

    # Calculate end of period dates
    # @param date_value [Symbol] the date keyword
    # @return [Date] the calculated date
    def calculate_period_end_date(date_value)
      case date_value
      when :this_weekend
        # Calculate days until Saturday
        days_until_saturday = (6 - Date.today.wday) % 7
        # If today is Saturday or Sunday, we're already on the weekend
        days_until_saturday = 0 if [0, 6].include?(Date.today.wday)
        Date.today + days_until_saturday
      when :end_of_week
        # Calculate days until Sunday (end of week)
        days_until_sunday = (0 - Date.today.wday) % 7
        # If today is Sunday, we're already at the end of the week
        days_until_sunday = 0 if days_until_sunday.zero?
        Date.today + days_until_sunday
      when :end_of_month
        # Return the last day of the current month
        # Get the first day of next month
        next_month = Date.today >> 1
        first_day_next_month = Date.new(next_month.year, next_month.month, 1)
        # Subtract one day to get the last day of current month
        first_day_next_month - 1
      when :end_of_year
        # Return the last day of the current year (December 31)
        Date.new(Date.today.year, 12, 31)
      end
    end

    # Calculate mid-period dates
    # @param date_value [Symbol] the date keyword
    # @return [Date] the calculated date
    def calculate_period_mid_date(date_value)
      case date_value
      when :mid_week
        # Return Wednesday of the current week
        # Calculate days until/since Wednesday (3)
        today_wday = Date.today.wday
        target_wday = 3 # Wednesday
        days_diff = (target_wday - today_wday) % 7
        # If the difference is more than 3, then Wednesday has passed this week
        # So we need to go back to Wednesday
        days_diff -= 7 if days_diff > 3
        Date.today + days_diff
      when :mid_month
        # Return the 15th day of the current month
        Date.new(Date.today.year, Date.today.month, 15)
      end
    end
  end
end
