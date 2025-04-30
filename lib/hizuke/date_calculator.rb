# frozen_string_literal: true

module Hizuke
  # Base module for date calculations
  module BaseCalculator
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

    # Handles date calculations for integer values (relative days)
    # @param date_value [Integer] number of days from today
    # @return [Date] calculated date
    def calculate_relative_days(date_value)
      Date.today + date_value
    end

    # Return mapping for week and month related date keywords
    # @return [Hash] Mapping of keywords to method names
    def temporal_period_methods
      {
        next_week: :calculate_week_date,
        last_week: :calculate_week_date,
        next_month: :calculate_month_date,
        last_month: :calculate_month_date
      }
    end

    # Return mapping for year and quarter related date keywords
    # @return [Hash] Mapping of keywords to method names
    def yearly_period_methods
      {
        next_year: :calculate_year_date,
        last_year: :calculate_year_date,
        next_quarter: :calculate_quarter_date,
        last_quarter: :calculate_quarter_date
      }
    end

    # Return mapping for special period related date keywords
    # @return [Hash] Mapping of keywords to method names
    def special_period_methods
      {
        this_weekend: :calculate_period_end_date,
        end_of_week: :calculate_period_end_date,
        end_of_month: :calculate_period_end_date,
        end_of_year: :calculate_period_end_date,
        mid_week: :calculate_period_mid_date,
        mid_month: :calculate_period_mid_date
      }
    end

    # Maps date value symbols to calculation methods
    # @return [Hash] the mapping of symbols to method names
    def date_calculation_methods
      temporal_period_methods.merge(yearly_period_methods).merge(special_period_methods)
    end

    # Calculate the date based on the keyword value
    # @param date_value [Symbol, Integer] the date value to calculate from
    # @return [Date] the calculated date
    def calculate_date(date_value)
      return calculate_relative_days(date_value) if date_value.is_a?(Integer)

      # Look up which method to call for this symbol
      method_name = date_calculation_methods[date_value]
      return unless method_name

      # Call the appropriate method with the date_value
      send(method_name, date_value)
    end
  end

  # Module for week-related date calculations
  module WeekCalculator
    # Calculate week-related dates
    # @param date_value [Symbol] the date keyword (:next_week or :last_week)
    # @return [Date] the calculated date
    def calculate_week_date(date_value)
      case date_value
      when :next_week
        calculate_next_week_date
      when :last_week
        calculate_last_week_date
      end
    end

    # Calculate date for next week
    # @return [Date] the date for next week (following Monday)
    def calculate_next_week_date
      # Find next Monday
      days_until_monday = (1 - Date.today.wday) % 7
      # If today is Monday, we want next Monday, not today
      days_until_monday = 7 if days_until_monday.zero?
      Date.today + days_until_monday
    end

    # Calculate date for last week
    # @return [Date] the date for last week (previous Monday)
    def calculate_last_week_date
      # Find last Monday
      days_since_monday = (Date.today.wday - 1) % 7
      # If today is Monday, we want last Monday, not today
      days_since_monday = 7 if days_since_monday.zero?
      Date.today - days_since_monday - 7
    end
  end

  # Module for month-related date calculations
  module MonthCalculator
    # Calculate month-related dates
    # @param date_value [Symbol] the date keyword (:next_month or :last_month)
    # @return [Date] the calculated date
    def calculate_month_date(date_value)
      case date_value
      when :next_month
        calculate_next_month_date
      when :last_month
        calculate_last_month_date
      end
    end

    # Calculate date for next month
    # @return [Date] the first day of the next month
    def calculate_next_month_date
      # Return the first day of the next month
      next_month = Date.today >> 1
      Date.new(next_month.year, next_month.month, 1)
    end

    # Calculate date for last month
    # @return [Date] the first day of the previous month
    def calculate_last_month_date
      # Return the first day of the previous month
      prev_month = Date.today << 1
      Date.new(prev_month.year, prev_month.month, 1)
    end
  end

  # Module for year-related date calculations
  module YearCalculator
    # Calculate year-related dates
    # @param date_value [Symbol] the date keyword (:next_year or :last_year)
    # @return [Date] the calculated date
    def calculate_year_date(date_value)
      case date_value
      when :next_year
        calculate_next_year_date
      when :last_year
        calculate_last_year_date
      end
    end

    # Calculate date for next year
    # @return [Date] the first day of the next year
    def calculate_next_year_date
      # Return the first day of the next year
      next_year = Date.today.year + 1
      Date.new(next_year, 1, 1)
    end

    # Calculate date for last year
    # @return [Date] the first day of the last year
    def calculate_last_year_date
      # Return the first day of the last year
      last_year = Date.today.year - 1
      Date.new(last_year, 1, 1)
    end
  end

  # Module for quarter-related date calculations
  module QuarterCalculator
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

      next_quarter_month = determine_next_quarter_month(current_month)
      next_quarter_year = determine_next_quarter_year(today.year, current_month)

      Date.new(next_quarter_year, next_quarter_month, 1)
    end

    # Determine the start month of the next quarter
    # @param current_month [Integer] the current month (1-12)
    # @return [Integer] the month number of the next quarter star
    def determine_next_quarter_month(current_month)
      if current_month <= 3
        4  # Q2 starts in April
      elsif current_month <= 6
        7  # Q3 starts in July
      elsif current_month <= 9
        10 # Q4 starts in October
      else
        1  # Q1 of next year starts in January
      end
    end

    # Determine the year of the next quarter
    # @param current_year [Integer] the current year
    # @param current_month [Integer] the current month (1-12)
    # @return [Integer] the year of the next quarter
    def determine_next_quarter_year(current_year, current_month)
      current_year + (current_month > 9 ? 1 : 0)
    end

    # Calculate the date for last quarter
    # @return [Date] the first day of the last quarter
    def calculate_last_quarter_date
      today = Date.today
      current_month = today.month

      last_quarter_month = determine_last_quarter_month(current_month)
      last_quarter_year = determine_last_quarter_year(today.year, current_month)

      Date.new(last_quarter_year, last_quarter_month, 1)
    end

    # Determine the start month of the last quarter
    # @param current_month [Integer] the current month (1-12)
    # @return [Integer] the month number of the last quarter star
    def determine_last_quarter_month(current_month)
      if current_month <= 3
        10 # Q4 of last year starts in October
      elsif current_month <= 6
        1  # Q1 starts in January
      elsif current_month <= 9
        4  # Q2 starts in April
      else
        7  # Q3 starts in July
      end
    end

    # Determine the year of the last quarter
    # @param current_year [Integer] the current year
    # @param current_month [Integer] the current month (1-12)
    # @return [Integer] the year of the last quarter
    def determine_last_quarter_year(current_year, current_month)
      current_year - (current_month <= 3 ? 1 : 0)
    end
  end

  # Module for period-related date calculations
  module PeriodCalculator
    # Calculate end of period dates
    # @param date_value [Symbol] the date keyword
    # @return [Date] the calculated date
    def calculate_period_end_date(date_value)
      case date_value
      when :this_weekend
        calculate_weekend_date
      when :end_of_week
        calculate_end_of_week_date
      when :end_of_month
        calculate_end_of_month_date
      when :end_of_year
        calculate_end_of_year_date
      end
    end

    # Calculate date for weekend (Saturday)
    # @return [Date] the date of the upcoming weekend
    def calculate_weekend_date
      # Calculate days until Saturday
      days_until_saturday = (6 - Date.today.wday) % 7
      # If today is Saturday or Sunday, we're already on the weekend
      days_until_saturday = 0 if [0, 6].include?(Date.today.wday)
      Date.today + days_until_saturday
    end

    # Calculate date for end of week (Sunday)
    # @return [Date] the date of the upcoming Sunday
    def calculate_end_of_week_date
      # Calculate days until Sunday (end of week)
      days_until_sunday = (0 - Date.today.wday) % 7
      # If today is Sunday, we're already at the end of the week
      days_until_sunday = 0 if days_until_sunday.zero?
      Date.today + days_until_sunday
    end

    # Calculate date for end of month
    # @return [Date] the last day of the current month
    def calculate_end_of_month_date
      # Return the last day of the current month
      # Get the first day of next month
      next_month = Date.today >> 1
      first_day_next_month = Date.new(next_month.year, next_month.month, 1)
      # Subtract one day to get the last day of current month
      first_day_next_month - 1
    end

    # Calculate date for end of year
    # @return [Date] the last day of the current year
    def calculate_end_of_year_date
      # Return the last day of the current year (December 31)
      Date.new(Date.today.year, 12, 31)
    end

    # Calculate mid-period dates
    # @param date_value [Symbol] the date keyword
    # @return [Date] the calculated date
    def calculate_period_mid_date(date_value)
      case date_value
      when :mid_week
        calculate_mid_week_date
      when :mid_month
        calculate_mid_month_date
      end
    end

    # Calculate date for mid-week (Wednesday)
    # @return [Date] the date of the current week's Wednesday
    def calculate_mid_week_date
      # Return Wednesday of the current week
      today_wday = Date.today.wday
      target_wday = 3 # Wednesday
      days_diff = (target_wday - today_wday) % 7
      # If the difference is more than 3, then Wednesday has passed this week
      # So we need to go back to Wednesday
      days_diff -= 7 if days_diff > 3
      Date.today + days_diff
    end

    # Calculate date for mid-month (15th)
    # @return [Date] the 15th day of the current month
    def calculate_mid_month_date
      # Return the 15th day of the current month
      Date.new(Date.today.year, Date.today.month, 15)
    end
  end

  # Main module for date calculations
  module DateCalculator
    include BaseCalculator
    include WeekCalculator
    include MonthCalculator
    include YearCalculator
    include QuarterCalculator
    include PeriodCalculator
  end
end
