# frozen_string_literal: true

require 'test_helper'

class TestParser < Minitest::Test
  def test_parse_tomorrow
    text = 'wash car tomorrow'
    tomorrow = Date.today + 1

    result = Hizuke::Parser.parse(text)

    assert_equal 'wash car', result.text
    assert_equal tomorrow, result.date
  end

  def test_parse_today
    text = 'buy groceries today'
    today = Date.today

    result = Hizuke::Parser.parse(text)

    assert_equal 'buy groceries', result.text
    assert_equal today, result.date
  end

  def test_parse_yesterday
    text = 'call mom yesterday'
    yesterday = Date.today - 1

    result = Hizuke::Parser.parse(text)

    assert_equal 'call mom', result.text
    assert_equal yesterday, result.date
  end

  def test_parse_mixed_case
    text = 'submit report ToDaY'
    today = Date.today

    result = Hizuke::Parser.parse(text)

    assert_equal 'submit report', result.text
    assert_equal today, result.date
  end

  def test_parse_with_punctuation
    text = 'finish presentation, tomorrow!'
    tomorrow = Date.today + 1

    result = Hizuke::Parser.parse(text)

    assert_equal 'finish presentation,', result.text
    assert_equal tomorrow, result.date
  end

  def test_date_keyword_in_middle
    text = 'discuss today project timeline'
    today = Date.today

    result = Hizuke::Parser.parse(text)

    assert_equal 'discuss project timeline', result.text
    assert_equal today, result.date
  end

  def test_parse_next_week
    text = 'team meeting next week'
    # Find next Monday
    days_until_monday = (1 - Date.today.wday) % 7
    # If today is Monday, we want next Monday, not today
    days_until_monday = 7 if days_until_monday.zero?
    next_monday = Date.today + days_until_monday

    result = Hizuke::Parser.parse(text)

    assert_equal 'team meeting', result.text
    assert_equal next_monday, result.date
  end

  def test_parse_next_month
    text = 'vacation next month'
    # Get first day of next month
    next_month = Date.today >> 1
    next_month_first_day = Date.new(next_month.year, next_month.month, 1)

    result = Hizuke::Parser.parse(text)

    assert_equal 'vacation', result.text
    assert_equal next_month_first_day, result.date
  end

  def test_parse_next_year
    text = 'conference next year'
    # Get first day of next year
    next_year_first_day = Date.new(Date.today.year + 1, 1, 1)

    result = Hizuke::Parser.parse(text)

    assert_equal 'conference', result.text
    assert_equal next_year_first_day, result.date
  end

  def test_parse_this_weekend
    text = 'hiking this weekend'
    # Calculate expected date (Saturday)
    days_until_saturday = (6 - Date.today.wday) % 7
    # If today is Saturday or Sunday, we're already on the weekend
    days_until_saturday = 0 if [0, 6].include?(days_until_saturday)
    expected_date = Date.today + days_until_saturday

    result = Hizuke::Parser.parse(text)

    assert_equal 'hiking', result.text
    assert_equal expected_date, result.date
  end

  def test_parse_without_spaces
    text = 'exam nextweek'
    # Find next Monday
    days_until_monday = (1 - Date.today.wday) % 7
    # If today is Monday, we want next Monday, not today
    days_until_monday = 7 if days_until_monday.zero?
    next_monday = Date.today + days_until_monday

    result = Hizuke::Parser.parse(text)

    assert_equal 'exam', result.text
    assert_equal next_monday, result.date
  end

  def test_raises_on_no_date_keyword
    text = 'wash car'

    assert_raises(Hizuke::ParseError) do
      Hizuke::Parser.parse(text)
    end
  end

  def test_raises_on_empty_input
    assert_raises(Hizuke::ParseError) do
      Hizuke::Parser.parse('')
    end
  end

  def test_raises_on_nil_input
    assert_raises(Hizuke::ParseError) do
      Hizuke::Parser.parse(nil)
    end
  end

  def test_parse_day_after_tomorrow
    text = 'meeting day after tomorrow'
    day_after_tomorrow = Date.today + 2

    result = Hizuke::Parser.parse(text)

    assert_equal 'meeting', result.text
    assert_equal day_after_tomorrow, result.date
  end

  def test_parse_dayaftertomorrow
    text = 'dentist appointment dayaftertomorrow'
    day_after_tomorrow = Date.today + 2

    result = Hizuke::Parser.parse(text)

    assert_equal 'dentist appointment', result.text
    assert_equal day_after_tomorrow, result.date
  end

  def test_parse_day_before_yesterday
    text = 'call mom day before yesterday'
    day_before_yesterday = Date.today - 2

    result = Hizuke::Parser.parse(text)

    assert_equal 'call mom', result.text
    assert_equal day_before_yesterday, result.date
  end

  def test_parse_daybeforeyesterday
    text = 'received package daybeforeyesterday'
    day_before_yesterday = Date.today - 2

    result = Hizuke::Parser.parse(text)

    assert_equal 'received package', result.text
    assert_equal day_before_yesterday, result.date
  end

  def test_parse_in_x_days
    text = 'exam in 5 days'
    expected_date = Date.today + 5

    result = Hizuke::Parser.parse(text)

    assert_equal 'exam', result.text
    assert_equal expected_date, result.date
  end

  def test_parse_x_days_ago
    text = 'submitted report 3 days ago'
    expected_date = Date.today - 3

    result = Hizuke::Parser.parse(text)

    assert_equal 'submitted report', result.text
    assert_equal expected_date, result.date
  end

  def test_parse_this_monday
    text = 'meeting this monday'
    today = Date.today
    target_day = 1 # Monday
    days_diff = (target_day - today.wday) % 7
    expected_date = days_diff.zero? ? today : today + days_diff

    result = Hizuke::Parser.parse(text)

    assert_equal 'meeting', result.text
    assert_equal expected_date, result.date
  end

  def test_parse_this_friday
    text = 'deadline this friday'
    today = Date.today
    target_day = 5 # Friday
    days_diff = (target_day - today.wday) % 7
    expected_date = days_diff.zero? ? today : today + days_diff

    result = Hizuke::Parser.parse(text)

    assert_equal 'deadline', result.text
    assert_equal expected_date, result.date
  end

  def test_parse_next_monday
    text = 'meeting next monday'
    today = Date.today
    target_day = 1 # Monday
    days_until_target = (target_day - today.wday) % 7
    days_until_target += 7 if days_until_target.zero? || target_day < today.wday
    expected_date = today + days_until_target

    result = Hizuke::Parser.parse(text)

    assert_equal 'meeting', result.text
    assert_equal expected_date, result.date
  end

  def test_parse_next_sunday
    text = 'brunch next sunday'
    today = Date.today
    target_day = 0 # Sunday
    days_until_target = (target_day - today.wday) % 7
    days_until_target += 7 if days_until_target.zero? || target_day < today.wday
    expected_date = today + days_until_target

    result = Hizuke::Parser.parse(text)

    assert_equal 'brunch', result.text
    assert_equal expected_date, result.date
  end

  def test_parse_last_wednesday
    text = 'sent email last wednesday'
    today = Date.today
    target_day = 3 # Wednesday
    days_since_target = (today.wday - target_day) % 7
    days_since_target += 7 if days_since_target.zero? || target_day > today.wday
    expected_date = today - days_since_target

    result = Hizuke::Parser.parse(text)

    assert_equal 'sent email', result.text
    assert_equal expected_date, result.date
  end

  def test_parse_last_saturday
    text = 'went shopping last saturday'
    today = Date.today
    target_day = 6 # Saturday
    days_since_target = (today.wday - target_day) % 7
    days_since_target += 7 if days_since_target.zero? || target_day > today.wday
    expected_date = today - days_since_target

    result = Hizuke::Parser.parse(text)

    assert_equal 'went shopping', result.text
    assert_equal expected_date, result.date
  end

  def test_parse_last_week
    text = 'conference last week'
    today = Date.today
    days_since_monday = (today.wday - 1) % 7
    days_since_monday = 7 if days_since_monday.zero?
    expected_date = today - days_since_monday - 7

    result = Hizuke::Parser.parse(text)

    assert_equal 'conference', result.text
    assert_equal expected_date, result.date
  end

  def test_parse_lastweek
    text = 'submitted report lastweek'
    today = Date.today
    days_since_monday = (today.wday - 1) % 7
    days_since_monday = 7 if days_since_monday.zero?
    expected_date = today - days_since_monday - 7

    result = Hizuke::Parser.parse(text)

    assert_equal 'submitted report', result.text
    assert_equal expected_date, result.date
  end

  def test_parse_in_x_weeks
    text = 'conference in 3 weeks'
    expected_date = Date.today + (3 * 7)

    result = Hizuke::Parser.parse(text)

    assert_equal 'conference', result.text
    assert_equal expected_date, result.date
  end

  def test_parse_x_weeks_ago
    text = 'started project 2 weeks ago'
    expected_date = Date.today - (2 * 7)

    result = Hizuke::Parser.parse(text)

    assert_equal 'started project', result.text
    assert_equal expected_date, result.date
  end

  def test_parse_last_month
    text = 'paid rent last month'
    today = Date.today
    prev_month = today << 1
    expected_date = Date.new(prev_month.year, prev_month.month, 1)

    result = Hizuke::Parser.parse(text)

    assert_equal 'paid rent', result.text
    assert_equal expected_date, result.date
  end

  def test_parse_lastmonth
    text = 'vacation lastmonth'
    today = Date.today
    prev_month = today << 1
    expected_date = Date.new(prev_month.year, prev_month.month, 1)

    result = Hizuke::Parser.parse(text)

    assert_equal 'vacation', result.text
    assert_equal expected_date, result.date
  end

  def test_parse_in_x_months
    text = 'conference in 3 months'
    today = Date.today
    future_date = today >> 3
    expected_date = future_date

    result = Hizuke::Parser.parse(text)

    assert_equal 'conference', result.text
    assert_equal expected_date, result.date
  end

  def test_parse_x_months_ago
    text = 'started working 6 months ago'
    today = Date.today
    past_date = today << 6
    expected_date = past_date

    result = Hizuke::Parser.parse(text)

    assert_equal 'started working', result.text
    assert_equal expected_date, result.date
  end

  def test_parse_last_year
    text = 'graduated last year'
    expected_date = Date.new(Date.today.year - 1, 1, 1)

    result = Hizuke::Parser.parse(text)

    assert_equal 'graduated', result.text
    assert_equal expected_date, result.date
  end

  def test_parse_lastyear
    text = 'vacation lastyear'
    expected_date = Date.new(Date.today.year - 1, 1, 1)

    result = Hizuke::Parser.parse(text)

    assert_equal 'vacation', result.text
    assert_equal expected_date, result.date
  end

  def test_parse_in_x_years
    text = 'retirement in 10 years'
    expected_date = Date.new(Date.today.year + 10, Date.today.month, Date.today.day)

    result = Hizuke::Parser.parse(text)

    assert_equal 'retirement', result.text
    assert_equal expected_date, result.date
  end

  def test_parse_x_years_ago
    text = 'started university 4 years ago'
    expected_date = Date.new(Date.today.year - 4, Date.today.month, Date.today.day)

    result = Hizuke::Parser.parse(text)

    assert_equal 'started university', result.text
    assert_equal expected_date, result.date
  end

  def test_parse_end_of_week
    text = 'project deadline end of week'
    # Calculate days until Sunday (end of week)
    days_until_sunday = (0 - Date.today.wday) % 7
    # If today is Sunday, we're already at the end of the week
    days_until_sunday = 0 if days_until_sunday.zero?
    expected_date = Date.today + days_until_sunday

    result = Hizuke::Parser.parse(text)

    assert_equal 'project deadline', result.text
    assert_equal expected_date, result.date
  end

  def test_parse_endofweek
    text = 'report due endofweek'
    # Calculate days until Sunday (end of week)
    days_until_sunday = (0 - Date.today.wday) % 7
    # If today is Sunday, we're already at the end of the week
    days_until_sunday = 0 if days_until_sunday.zero?
    expected_date = Date.today + days_until_sunday

    result = Hizuke::Parser.parse(text)

    assert_equal 'report due', result.text
    assert_equal expected_date, result.date
  end

  def test_parse_end_of_month
    text = 'rent payment end of month'
    # Get the first day of next month
    next_month = Date.today >> 1
    first_day_next_month = Date.new(next_month.year, next_month.month, 1)
    # Subtract one day to get the last day of current month
    expected_date = first_day_next_month - 1

    result = Hizuke::Parser.parse(text)

    assert_equal 'rent payment', result.text
    assert_equal expected_date, result.date
  end

  def test_parse_endofmonth
    text = 'salary endofmonth'
    # Get the first day of next month
    next_month = Date.today >> 1
    first_day_next_month = Date.new(next_month.year, next_month.month, 1)
    # Subtract one day to get the last day of current month
    expected_date = first_day_next_month - 1

    result = Hizuke::Parser.parse(text)

    assert_equal 'salary', result.text
    assert_equal expected_date, result.date
  end

  def test_parse_end_of_year
    text = 'bonus payment end of year'
    expected_date = Date.new(Date.today.year, 12, 31)

    result = Hizuke::Parser.parse(text)

    assert_equal 'bonus payment', result.text
    assert_equal expected_date, result.date
  end

  def test_parse_endofyear
    text = 'tax filing endofyear'
    expected_date = Date.new(Date.today.year, 12, 31)

    result = Hizuke::Parser.parse(text)

    assert_equal 'tax filing', result.text
    assert_equal expected_date, result.date
  end

  def test_parse_mid_week
    text = 'team meeting mid week'
    # Calculate days until/since Wednesday (3)
    today_wday = Date.today.wday
    target_wday = 3 # Wednesday
    days_diff = (target_wday - today_wday) % 7
    # If the difference is more than 3, then Wednesday has passed this week
    # So we need to go back to Wednesday
    days_diff -= 7 if days_diff > 3
    expected_date = Date.today + days_diff

    result = Hizuke::Parser.parse(text)

    assert_equal 'team meeting', result.text
    assert_equal expected_date, result.date
  end

  def test_parse_midweek
    text = 'client call midweek'
    # Calculate days until/since Wednesday (3)
    today_wday = Date.today.wday
    target_wday = 3 # Wednesday
    days_diff = (target_wday - today_wday) % 7
    # If the difference is more than 3, then Wednesday has passed this week
    # So we need to go back to Wednesday
    days_diff -= 7 if days_diff > 3
    expected_date = Date.today + days_diff

    result = Hizuke::Parser.parse(text)

    assert_equal 'client call', result.text
    assert_equal expected_date, result.date
  end

  def test_parse_mid_month
    text = 'performance review mid month'
    expected_date = Date.new(Date.today.year, Date.today.month, 15)

    result = Hizuke::Parser.parse(text)

    assert_equal 'performance review', result.text
    assert_equal expected_date, result.date
  end

  def test_parse_midmonth
    text = 'budget planning midmonth'
    expected_date = Date.new(Date.today.year, Date.today.month, 15)

    result = Hizuke::Parser.parse(text)

    assert_equal 'budget planning', result.text
    assert_equal expected_date, result.date
  end

  def test_parse_next_quarter
    text = 'planning session next quarter'

    # Determine expected date for the next quarter
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

    expected_date = Date.new(next_quarter_year, next_quarter_month, 1)

    result = Hizuke::Parser.parse(text)

    assert_equal 'planning session', result.text
    assert_equal expected_date, result.date
  end

  def test_parse_nextquarter
    text = 'budget review nextquarter'

    # Determine expected date for the next quarter
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

    expected_date = Date.new(next_quarter_year, next_quarter_month, 1)

    result = Hizuke::Parser.parse(text)

    assert_equal 'budget review', result.text
    assert_equal expected_date, result.date
  end

  def test_parse_last_quarter
    text = 'performance analysis last quarter'

    # Determine expected date for the last quarter
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

    expected_date = Date.new(last_quarter_year, last_quarter_month, 1)

    result = Hizuke::Parser.parse(text)

    assert_equal 'performance analysis', result.text
    assert_equal expected_date, result.date
  end

  def test_parse_lastquarter
    text = 'financial report lastquarter'

    # Determine expected date for the last quarter
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

    expected_date = Date.new(last_quarter_year, last_quarter_month, 1)

    result = Hizuke::Parser.parse(text)

    assert_equal 'financial report', result.text
    assert_equal expected_date, result.date
  end

  # Tests for time parsing
  def test_parse_with_time
    text = 'meeting tomorrow at 10'
    tomorrow = Date.today + 1

    result = Hizuke::Parser.parse(text)

    assert_equal 'meeting', result.text
    assert_equal tomorrow, result.date
    assert_equal 10, result.time.hour
    assert_equal 0, result.time.min
    assert_equal '10:00', result.time.to_s
  end

  def test_parse_with_time_am
    text = 'call doctor tomorrow at 9am'
    tomorrow = Date.today + 1

    result = Hizuke::Parser.parse(text)

    assert_equal 'call doctor', result.text
    assert_equal tomorrow, result.date
    assert_equal 9, result.time.hour
    assert_equal 0, result.time.min
    assert_equal '09:00', result.time.to_s
  end

  def test_parse_with_time_pm
    text = 'dinner today at 7pm'
    today = Date.today

    result = Hizuke::Parser.parse(text)

    assert_equal 'dinner', result.text
    assert_equal today, result.date
    assert_equal 19, result.time.hour
    assert_equal 0, result.time.min
    assert_equal '19:00', result.time.to_s
  end

  def test_parse_with_time_minutes
    text = 'meeting tomorrow at 10:30'
    tomorrow = Date.today + 1

    result = Hizuke::Parser.parse(text)

    assert_equal 'meeting', result.text
    assert_equal tomorrow, result.date
    assert_equal 10, result.time.hour
    assert_equal 30, result.time.min
    assert_equal '10:30', result.time.to_s
  end

  def test_parse_with_time_hours_minutes_seconds
    text = 'start recording today at 14:30:45'
    today = Date.today

    result = Hizuke::Parser.parse(text)

    assert_equal 'start recording', result.text
    assert_equal today, result.date
    assert_equal 14, result.time.hour
    assert_equal 30, result.time.min
    assert_equal 45, result.time.sec
    assert_equal '14:30:45', result.time.to_s
  end

  def test_parse_with_at_symbol
    text = 'meeting tomorrow @ 10'
    tomorrow = Date.today + 1

    result = Hizuke::Parser.parse(text)

    assert_equal 'meeting', result.text
    assert_equal tomorrow, result.date
    assert_equal 10, result.time.hour
    assert_equal 0, result.time.min
    assert_equal '10:00', result.time.to_s
  end

  def test_time_with_noon_pm
    text = 'lunch meeting tomorrow at 12pm'
    tomorrow = Date.today + 1

    result = Hizuke::Parser.parse(text)

    assert_equal 'lunch meeting', result.text
    assert_equal tomorrow, result.date
    assert_equal 12, result.time.hour
    assert_equal 0, result.time.min
    assert_equal '12:00', result.time.to_s
  end

  def test_time_with_midnight_am
    text = 'airport pickup today at 12am'
    today = Date.today

    result = Hizuke::Parser.parse(text)

    assert_equal 'airport pickup', result.text
    assert_equal today, result.date
    assert_equal 0, result.time.hour
    assert_equal 0, result.time.min
    assert_equal '00:00', result.time.to_s
  end

  def test_datetime_method
    text = 'meeting tomorrow at 10:30'
    tomorrow = Date.today + 1
    expected_datetime = Time.new(tomorrow.year, tomorrow.month, tomorrow.day, 10, 30, 0)

    result = Hizuke::Parser.parse(text)

    assert_equal 'meeting', result.text
    assert_equal tomorrow, result.date
    assert_equal expected_datetime.year, result.datetime.year
    assert_equal expected_datetime.month, result.datetime.month
    assert_equal expected_datetime.day, result.datetime.day
    assert_equal expected_datetime.hour, result.datetime.hour
    assert_equal expected_datetime.min, result.datetime.min
  end

  def test_datetime_with_no_time_returns_nil
    text = 'meeting tomorrow'

    result = Hizuke::Parser.parse(text)

    assert_nil result.datetime
  end

  # Tests for word-based time parsing
  def test_parse_with_noon
    text = 'meeting tomorrow at noon'
    tomorrow = Date.today + 1

    result = Hizuke::Parser.parse(text)

    assert_equal 'meeting', result.text
    assert_equal tomorrow, result.date
    assert_equal 12, result.time.hour
    assert_equal 0, result.time.min
    assert_equal '12:00', result.time.to_s
  end

  def test_parse_with_midnight
    text = 'flight today at midnight'
    today = Date.today

    result = Hizuke::Parser.parse(text)

    assert_equal 'flight', result.text
    assert_equal today, result.date
    assert_equal 0, result.time.hour
    assert_equal 0, result.time.min
    assert_equal '00:00', result.time.to_s
  end

  def test_parse_with_morning
    text = 'team meeting tomorrow in the morning'
    tomorrow = Date.today + 1

    result = Hizuke::Parser.parse(text)

    assert_equal 'team meeting', result.text
    assert_equal tomorrow, result.date
    assert_equal 8, result.time.hour
    assert_equal 0, result.time.min
    assert_equal '08:00', result.time.to_s
  end

  def test_parse_with_evening
    text = 'dinner today in the evening'
    today = Date.today

    result = Hizuke::Parser.parse(text)

    assert_equal 'dinner', result.text
    assert_equal today, result.date
    assert_equal 20, result.time.hour
    assert_equal 0, result.time.min
    assert_equal '20:00', result.time.to_s
  end

  def test_configure_morning_time
    original_config = Hizuke.configuration.morning_time

    begin
      Hizuke.configure do |config|
        config.morning_time = { hour: 9, min: 30 }
      end

      text = 'breakfast tomorrow in the morning'
      tomorrow = Date.today + 1

      result = Hizuke::Parser.parse(text)

      assert_equal 'breakfast', result.text
      assert_equal tomorrow, result.date
      assert_equal 9, result.time.hour
      assert_equal 30, result.time.min
      assert_equal '09:30', result.time.to_s
    ensure
      # Restore the original configuration
      Hizuke.configure do |config|
        config.morning_time = original_config
      end
    end
  end

  def test_configure_evening_time
    original_config = Hizuke.configuration.evening_time

    begin
      Hizuke.configure do |config|
        config.evening_time = { hour: 19, min: 0 }
      end

      text = 'dinner today in the evening'
      today = Date.today

      result = Hizuke::Parser.parse(text)

      assert_equal 'dinner', result.text
      assert_equal today, result.date
      assert_equal 19, result.time.hour
      assert_equal 0, result.time.min
      assert_equal '19:00', result.time.to_s
    ensure
      # Restore the original configuration
      Hizuke.configure do |config|
        config.evening_time = original_config
      end
    end
  end
end
