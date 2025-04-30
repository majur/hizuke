# frozen_string_literal: true

module Hizuke
  # Module for handling holidays and notable days
  module Holidays
    # Static holidays - days that occur on the same date each year
    STATIC_HOLIDAYS = {
      'new year' => ->(year) { Date.new(year, 1, 1) },
      'new years day' => ->(year) { Date.new(year, 1, 1) },
      'new year day' => ->(year) { Date.new(year, 1, 1) },
      'new years eve' => ->(year) { Date.new(year, 12, 31) },
      'new year eve' => ->(year) { Date.new(year, 12, 31) },
      'christmas' => ->(year) { Date.new(year, 12, 25) },
      'christmas eve' => ->(year) { Date.new(year, 12, 24) },
      'christmas day' => ->(year) { Date.new(year, 12, 25) },
      'valentines day' => ->(year) { Date.new(year, 2, 14) },
      'valentine day' => ->(year) { Date.new(year, 2, 14) },
      'halloween' => ->(year) { Date.new(year, 10, 31) },
      'independence day' => ->(year) { Date.new(year, 7, 4) }, # USA
      'st patricks day' => ->(year) { Date.new(year, 3, 17) },
      'st patrick day' => ->(year) { Date.new(year, 3, 17) },
      'april fools day' => ->(year) { Date.new(year, 4, 1) },
      'april fool day' => ->(year) { Date.new(year, 4, 1) },
      'earth day' => ->(year) { Date.new(year, 4, 22) },
      'may day' => ->(year) { Date.new(year, 5, 1) }
    }.freeze

    # Dynamic holidays - holidays that need computation to determine their date
    DYNAMIC_HOLIDAYS = {
      'easter' => ->(year) { calculate_easter(year) },
      'good friday' => ->(year) { calculate_easter(year) - 2 },
      'easter monday' => ->(year) { calculate_easter(year) + 1 },
      'mothers day' => ->(year) { calculate_nth_day_of_month(year, 5, 0, 2) }, # Second Sunday in May
      'mother day' => ->(year) { calculate_nth_day_of_month(year, 5, 0, 2) }, # Second Sunday in May
      'fathers day' => ->(year) { calculate_nth_day_of_month(year, 6, 0, 3) }, # Third Sunday in June
      'father day' => ->(year) { calculate_nth_day_of_month(year, 6, 0, 3) }, # Third Sunday in June
      'thanksgiving' => ->(year) { calculate_nth_day_of_month(year, 11, 4, 4) }, # Fourth Thursday in November
      'labor day' => ->(year) { calculate_first_day_of_month(year, 9, 1) }, # First Monday in September
      'memorial day' => ->(year) { calculate_last_day_of_month(year, 5, 1) } # Last Monday in May
    }.freeze

    # All holidays combined
    ALL_HOLIDAYS = STATIC_HOLIDAYS.merge(DYNAMIC_HOLIDAYS).freeze

    # Calculate Easter Sunday for a given year (using Butcher's algorithm)
    # @param year [Integer] the year to calculate Easter for
    # @return [Date] the date of Easter Sunday
    def self.calculate_easter(year)
      # Calculate intermediate values using Butcher's algorithm
      intermediate_values = calculate_easter_intermediate_values(year)

      # Calculate final month and day
      month, day = calculate_easter_date(intermediate_values)

      Date.new(year, month, day)
    end

    # Calculate intermediate values for Easter calculation
    # @param year [Integer] the year to calculate Easter for
    # @return [Hash] hash of intermediate values
    def self.calculate_easter_intermediate_values(year)
      # First part of Butcher's algorithm - year specific calculations
      year_values = calculate_year_values(year)

      # Second part of calculations
      h = calculate_h_value(year_values)
      i = year_values[:c] / 4
      k = year_values[:c] % 4
      l = (32 + (2 * year_values[:e]) + (2 * i) - h - k) % 7
      m = (year_values[:a] + (11 * h) + (22 * l)) / 451

      {
        h: h,
        l: l,
        m: m
      }
    end

    # Calculate initial year-specific values for Easter calculation
    # @param year [Integer] the year
    # @return [Hash] hash of year-specific values
    def self.calculate_year_values(year)
      a = year % 19
      b = year / 100
      c = year % 100
      d = b / 4
      e = b % 4
      f = (b + 8) / 25
      g = (b - f + 1) / 3

      {
        a: a,
        b: b,
        c: c,
        d: d,
        e: e,
        f: f,
        g: g
      }
    end

    # Calculate the h value in Butcher's algorithm
    # @param values [Hash] hash of year-specific values
    # @return [Integer] h value
    def self.calculate_h_value(values)
      ((19 * values[:a]) + values[:b] - values[:d] - values[:g] + 15) % 30
    end

    # Calculate the final Easter date from intermediate values
    # @param values [Hash] hash of intermediate values
    # @return [Array<Integer>] array of [month, day]
    def self.calculate_easter_date(values)
      h = values[:h]
      l = values[:l]
      m = values[:m]

      month = (h + l - (7 * m) + 114) / 31
      day = ((h + l - (7 * m) + 114) % 31) + 1

      [month, day]
    end

    # Calculate the nth occurrence of a day in a month
    # @param year [Integer] the year
    # @param month [Integer] the month (1-12)
    # @param wday [Integer] the day of week (0-6, Sunday is 0)
    # @param occurrence [Integer] which occurrence (1-5)
    # @return [Date] the calculated date
    def self.calculate_nth_day_of_month(year, month, wday, occurrence)
      # Find the first day of the month
      date = Date.new(year, month, 1)

      # Find the first occurrence of the day in the month
      days_until_first = (wday - date.wday) % 7
      first_occurrence = date + days_until_first

      # Calculate the nth occurrence
      first_occurrence + ((occurrence - 1) * 7)
    end

    # Calculate the first occurrence of a day in a month
    # @param year [Integer] the year
    # @param month [Integer] the month (1-12)
    # @param wday [Integer] the day of week (0-6, Sunday is 0)
    # @return [Date] the calculated date
    def self.calculate_first_day_of_month(year, month, wday)
      calculate_nth_day_of_month(year, month, wday, 1)
    end

    # Calculate the last occurrence of a day in a month
    # @param year [Integer] the year
    # @param month [Integer] the month (1-12)
    # @param wday [Integer] the day of week (0-6, Sunday is 0)
    # @return [Date] the calculated date
    def self.calculate_last_day_of_month(year, month, wday)
      # Find the last day of the month
      last_day = Date.new(year, month, -1)
      days_to_last = (wday - last_day.wday) % 7

      # If days_to_last is 0, we're already on the right day of the week
      # Otherwise, we need to go back to the previous occurrence
      last_day - (days_to_last.zero? ? 0 : 7 - days_to_last)
    end
  end
end
