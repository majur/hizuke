# frozen_string_literal: true

module Hizuke
  # Module containing constants used throughout Hizuke
  module Constants
    # Mapping of day names to their wday values (0-6, Sunday is 0)
    DAYS_OF_WEEK = {
      'monday' => 1,
      'tuesday' => 2,
      'wednesday' => 3,
      'thursday' => 4,
      'friday' => 5,
      'saturday' => 6,
      'sunday' => 0
    }.freeze

    # Date keywords mapping
    DATE_KEYWORDS = {
      'yesterday' => -1,
      'today' => 0,
      'tomorrow' => 1,
      'dayaftertomorrow' => 2,
      'day after tomorrow' => 2,
      'daybeforeyesterday' => -2,
      'day before yesterday' => -2,
      'nextweek' => :next_week,
      'next week' => :next_week,
      'lastweek' => :last_week,
      'last week' => :last_week,
      'nextmonth' => :next_month,
      'next month' => :next_month,
      'lastmonth' => :last_month,
      'last month' => :last_month,
      'nextyear' => :next_year,
      'next year' => :next_year,
      'lastyear' => :last_year,
      'last year' => :last_year,
      'nextquarter' => :next_quarter,
      'next quarter' => :next_quarter,
      'lastquarter' => :last_quarter,
      'last quarter' => :last_quarter,
      'thisweekend' => :this_weekend,
      'this weekend' => :this_weekend,
      'endofweek' => :end_of_week,
      'end of week' => :end_of_week,
      'endofmonth' => :end_of_month,
      'end of month' => :end_of_month,
      'endofyear' => :end_of_year,
      'end of year' => :end_of_year,
      'midweek' => :mid_week,
      'mid week' => :mid_week,
      'midmonth' => :mid_month,
      'mid month' => :mid_month,
      'christmas' => :christmas,
      'xmas' => :christmas,
      'nextchristmas' => :next_christmas,
      'next christmas' => :next_christmas,
      'lastchristmas' => :last_christmas,
      'last christmas' => :last_christmas
    }.freeze

    # Regex patterns for dynamic date references
    IN_X_DAYS_PATTERN = /in (\d+) days?/i.freeze
    X_DAYS_AGO_PATTERN = /(\d+) days? ago/i.freeze
    IN_X_WEEKS_PATTERN = /in (\d+) weeks?/i.freeze
    X_WEEKS_AGO_PATTERN = /(\d+) weeks? ago/i.freeze
    IN_X_MONTHS_PATTERN = /in (\d+) months?/i.freeze
    X_MONTHS_AGO_PATTERN = /(\d+) months? ago/i.freeze
    IN_X_YEARS_PATTERN = /in (\d+) years?/i.freeze
    X_YEARS_AGO_PATTERN = /(\d+) years? ago/i.freeze

    # Regex patterns for specific days of the week
    THIS_DAY_PATTERN = /this (monday|tuesday|wednesday|thursday|friday|saturday|sunday)/i.freeze
    NEXT_DAY_PATTERN = /next (monday|tuesday|wednesday|thursday|friday|saturday|sunday)/i.freeze
    LAST_DAY_PATTERN = /last (monday|tuesday|wednesday|thursday|friday|saturday|sunday)/i.freeze

    # Regex patterns for time references
    TIME_PATTERN = /(?:at|@)\s*(\d{1,2})(?::(\d{1,2}))?(?::(\d{1,2}))?\s*(am|pm)?/i.freeze

    # Regex patterns for word-based time references
    NOON_PATTERN = /at\s+noon/i.freeze
    MIDNIGHT_PATTERN = /at\s+midnight/i.freeze
    MORNING_PATTERN = /in\s+the\s+morning/i.freeze
    EVENING_PATTERN = /in\s+the\s+evening/i.freeze
  end
end
