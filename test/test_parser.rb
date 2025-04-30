# frozen_string_literal: true

require 'test_helper'

# Základná trieda pre zdieľané pomocné metódy
class BaseParserTest < Minitest::Test
  def parse_and_assert(text, expected_text, expected_date)
    result = Hizuke::Parser.parse(text)
    assert_equal expected_text, result.text
    assert_equal expected_date, result.date
    result
  end
end

# Testy pre základné dátumové výrazy
class BasicDateParserTest < BaseParserTest
  def test_parse_tomorrow
    parse_and_assert('wash car tomorrow', 'wash car', Date.today + 1)
  end

  def test_parse_today
    parse_and_assert('buy groceries today', 'buy groceries', Date.today)
  end

  def test_parse_yesterday
    parse_and_assert('call mom yesterday', 'call mom', Date.today - 1)
  end

  def test_parse_mixed_case
    parse_and_assert('submit report ToDaY', 'submit report', Date.today)
  end

  def test_parse_with_punctuation
    parse_and_assert('finish presentation, tomorrow!', 'finish presentation,', Date.today + 1)
  end

  def test_date_keyword_in_middle
    parse_and_assert('discuss today project timeline', 'discuss project timeline', Date.today)
  end

  def test_parse_day_after_tomorrow
    parse_and_assert('meeting day after tomorrow', 'meeting', Date.today + 2)
  end

  def test_parse_dayaftertomorrow
    parse_and_assert('dentist appointment dayaftertomorrow', 'dentist appointment', Date.today + 2)
  end

  def test_parse_day_before_yesterday
    parse_and_assert('call mom day before yesterday', 'call mom', Date.today - 2)
  end

  def test_parse_daybeforeyesterday
    parse_and_assert('received package daybeforeyesterday', 'received package', Date.today - 2)
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
end

# Testy pre relatívne dátumové výrazy (X dní/týždňov/mesiacov/rokov dopredu/dozadu)
class RelativeDateParserTest < BaseParserTest
  def test_parse_in_x_days
    parse_and_assert('exam in 5 days', 'exam', Date.today + 5)
  end

  def test_parse_x_days_ago
    parse_and_assert('submitted report 3 days ago', 'submitted report', Date.today - 3)
  end

  def test_parse_in_x_weeks
    parse_and_assert('conference in 3 weeks', 'conference', Date.today + (3 * 7))
  end

  def test_parse_x_weeks_ago
    parse_and_assert('started project 2 weeks ago', 'started project', Date.today - (2 * 7))
  end

  def test_parse_in_x_months
    today = Date.today
    future_date = today >> 3
    parse_and_assert('conference in 3 months', 'conference', future_date)
  end

  def test_parse_x_months_ago
    today = Date.today
    past_date = today << 6
    parse_and_assert('started working 6 months ago', 'started working', past_date)
  end

  def test_parse_in_x_years
    expected_date = Date.new(Date.today.year + 10, Date.today.month, Date.today.day)
    parse_and_assert('retirement in 10 years', 'retirement', expected_date)
  end

  def test_parse_x_years_ago
    expected_date = Date.new(Date.today.year - 4, Date.today.month, Date.today.day)
    parse_and_assert('started university 4 years ago', 'started university', expected_date)
  end
end

# Testy pre výrazy so dňami v týždni
class DayOfWeekParserTest < BaseParserTest
  def test_parse_this_monday
    today = Date.today
    target_day = 1 # Monday
    days_diff = (target_day - today.wday) % 7
    expected_date = days_diff.zero? ? today : today + days_diff

    parse_and_assert('meeting this monday', 'meeting', expected_date)
  end

  def test_parse_this_friday
    today = Date.today
    target_day = 5 # Friday
    days_diff = (target_day - today.wday) % 7
    expected_date = days_diff.zero? ? today : today + days_diff

    parse_and_assert('deadline this friday', 'deadline', expected_date)
  end

  def test_parse_next_monday
    today = Date.today
    target_day = 1 # Monday
    days_until_target = (target_day - today.wday) % 7
    days_until_target += 7 if days_until_target.zero? || target_day < today.wday
    expected_date = today + days_until_target

    parse_and_assert('meeting next monday', 'meeting', expected_date)
  end

  def test_parse_next_sunday
    today = Date.today
    target_day = 0 # Sunday
    days_until_target = (target_day - today.wday) % 7
    days_until_target += 7 if days_until_target.zero? || target_day < today.wday
    expected_date = today + days_until_target

    parse_and_assert('brunch next sunday', 'brunch', expected_date)
  end

  def test_parse_last_wednesday
    today = Date.today
    target_day = 3 # Wednesday
    days_since_target = (today.wday - target_day) % 7
    days_since_target += 7 if days_since_target.zero? || target_day > today.wday
    expected_date = today - days_since_target

    parse_and_assert('sent email last wednesday', 'sent email', expected_date)
  end

  def test_parse_last_saturday
    today = Date.today
    target_day = 6 # Saturday
    days_since_target = (today.wday - target_day) % 7
    days_since_target += 7 if days_since_target.zero? || target_day > today.wday
    expected_date = today - days_since_target

    parse_and_assert('went shopping last saturday', 'went shopping', expected_date)
  end
end

# Testy pre týždenné, mesačné a ročné výrazy
class PeriodParserTest < BaseParserTest
  def test_parse_next_week
    # Find next Monday
    days_until_monday = (1 - Date.today.wday) % 7
    # If today is Monday, we want next Monday, not today
    days_until_monday = 7 if days_until_monday.zero?
    next_monday = Date.today + days_until_monday

    parse_and_assert('team meeting next week', 'team meeting', next_monday)
  end

  def test_parse_next_month
    # Get first day of next month
    next_month = Date.today >> 1
    next_month_first_day = Date.new(next_month.year, next_month.month, 1)

    parse_and_assert('vacation next month', 'vacation', next_month_first_day)
  end

  def test_parse_next_year
    # Get first day of next year
    next_year_first_day = Date.new(Date.today.year + 1, 1, 1)

    parse_and_assert('conference next year', 'conference', next_year_first_day)
  end

  def test_parse_this_weekend
    # Calculate expected date (Saturday)
    days_until_saturday = (6 - Date.today.wday) % 7
    # If today is Saturday or Sunday, we're already on the weekend
    days_until_saturday = 0 if [0, 6].include?(Date.today.wday)
    expected_date = Date.today + days_until_saturday

    parse_and_assert('hiking this weekend', 'hiking', expected_date)
  end

  def test_parse_without_spaces
    # Find next Monday
    days_until_monday = (1 - Date.today.wday) % 7
    # If today is Monday, we want next Monday, not today
    days_until_monday = 7 if days_until_monday.zero?
    next_monday = Date.today + days_until_monday

    parse_and_assert('exam nextweek', 'exam', next_monday)
  end

  def test_parse_last_week
    today = Date.today
    days_since_monday = (today.wday - 1) % 7
    days_since_monday = 7 if days_since_monday.zero?
    expected_date = today - days_since_monday - 7

    parse_and_assert('conference last week', 'conference', expected_date)
  end

  def test_parse_lastweek
    today = Date.today
    days_since_monday = (today.wday - 1) % 7
    days_since_monday = 7 if days_since_monday.zero?
    expected_date = today - days_since_monday - 7

    parse_and_assert('submitted report lastweek', 'submitted report', expected_date)
  end

  def test_parse_last_month
    today = Date.today
    prev_month = today << 1
    expected_date = Date.new(prev_month.year, prev_month.month, 1)

    parse_and_assert('paid rent last month', 'paid rent', expected_date)
  end

  def test_parse_lastmonth
    today = Date.today
    prev_month = today << 1
    expected_date = Date.new(prev_month.year, prev_month.month, 1)

    parse_and_assert('vacation lastmonth', 'vacation', expected_date)
  end

  def test_parse_last_year
    expected_date = Date.new(Date.today.year - 1, 1, 1)

    parse_and_assert('graduated last year', 'graduated', expected_date)
  end

  def test_parse_lastyear
    expected_date = Date.new(Date.today.year - 1, 1, 1)

    parse_and_assert('vacation lastyear', 'vacation', expected_date)
  end
end

# Testy pre výrazy s kvartálmi
class QuarterParserTest < BaseParserTest
  def next_quarter_month(current_month)
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

  def last_quarter_month(current_month)
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

  def calculate_next_quarter_date
    today = Date.today
    current_month = today.month
    next_q_month = next_quarter_month(current_month)
    next_q_year = today.year + (current_month > 9 ? 1 : 0)
    Date.new(next_q_year, next_q_month, 1)
  end

  def calculate_last_quarter_date
    today = Date.today
    current_month = today.month
    last_q_month = last_quarter_month(current_month)
    last_q_year = today.year - (current_month <= 3 ? 1 : 0)
    Date.new(last_q_year, last_q_month, 1)
  end

  def test_parse_next_quarter
    expected_date = calculate_next_quarter_date
    parse_and_assert('planning session next quarter', 'planning session', expected_date)
  end

  def test_parse_nextquarter
    expected_date = calculate_next_quarter_date
    parse_and_assert('budget review nextquarter', 'budget review', expected_date)
  end

  def test_parse_last_quarter
    expected_date = calculate_last_quarter_date
    parse_and_assert('performance analysis last quarter', 'performance analysis', expected_date)
  end

  def test_parse_lastquarter
    expected_date = calculate_last_quarter_date
    parse_and_assert('financial report lastquarter', 'financial report', expected_date)
  end
end

# Testy pre výrazy s výnimočnými obdobiami (koniec týždňa, mesiaca, roka, stred týždňa, atď.)
class SpecialPeriodParserTest < BaseParserTest
  def test_parse_end_of_week
    # Calculate days until Sunday (end of week)
    days_until_sunday = (0 - Date.today.wday) % 7
    # If today is Sunday, we're already at the end of the week
    days_until_sunday = 0 if days_until_sunday.zero?
    expected_date = Date.today + days_until_sunday

    parse_and_assert('project deadline end of week', 'project deadline', expected_date)
  end

  def test_parse_endofweek
    # Calculate days until Sunday (end of week)
    days_until_sunday = (0 - Date.today.wday) % 7
    # If today is Sunday, we're already at the end of the week
    days_until_sunday = 0 if days_until_sunday.zero?
    expected_date = Date.today + days_until_sunday

    parse_and_assert('report due endofweek', 'report due', expected_date)
  end

  def test_parse_end_of_month
    # Get the first day of next month
    next_month = Date.today >> 1
    first_day_next_month = Date.new(next_month.year, next_month.month, 1)
    # Subtract one day to get the last day of current month
    expected_date = first_day_next_month - 1

    parse_and_assert('rent payment end of month', 'rent payment', expected_date)
  end

  def test_parse_endofmonth
    # Get the first day of next month
    next_month = Date.today >> 1
    first_day_next_month = Date.new(next_month.year, next_month.month, 1)
    # Subtract one day to get the last day of current month
    expected_date = first_day_next_month - 1

    parse_and_assert('salary endofmonth', 'salary', expected_date)
  end

  def test_parse_end_of_year
    expected_date = Date.new(Date.today.year, 12, 31)

    parse_and_assert('bonus payment end of year', 'bonus payment', expected_date)
  end

  def test_parse_endofyear
    expected_date = Date.new(Date.today.year, 12, 31)

    parse_and_assert('tax filing endofyear', 'tax filing', expected_date)
  end

  def test_parse_mid_week
    # Calculate days until/since Wednesday (3)
    today_wday = Date.today.wday
    target_wday = 3 # Wednesday
    days_diff = (target_wday - today_wday) % 7
    # If the difference is more than 3, then Wednesday has passed this week
    # So we need to go back to Wednesday
    days_diff -= 7 if days_diff > 3
    expected_date = Date.today + days_diff

    parse_and_assert('team meeting mid week', 'team meeting', expected_date)
  end

  def test_parse_midweek
    # Calculate days until/since Wednesday (3)
    today_wday = Date.today.wday
    target_wday = 3 # Wednesday
    days_diff = (target_wday - today_wday) % 7
    # If the difference is more than 3, then Wednesday has passed this week
    # So we need to go back to Wednesday
    days_diff -= 7 if days_diff > 3
    expected_date = Date.today + days_diff

    parse_and_assert('client call midweek', 'client call', expected_date)
  end

  def test_parse_mid_month
    expected_date = Date.new(Date.today.year, Date.today.month, 15)

    parse_and_assert('performance review mid month', 'performance review', expected_date)
  end

  def test_parse_midmonth
    expected_date = Date.new(Date.today.year, Date.today.month, 15)

    parse_and_assert('budget planning midmonth', 'budget planning', expected_date)
  end
end

# Testy pre číselne zadaný čas (at 10, at 9am, atď.)
class NumericTimeParserTest < BaseParserTest
  def test_parse_with_time
    text = 'meeting tomorrow at 10'
    tomorrow = Date.today + 1

    result = parse_and_assert(text, 'meeting', tomorrow)

    assert_equal 10, result.time.hour
    assert_equal 0, result.time.min
    assert_equal '10:00', result.time.to_s
  end

  def test_parse_with_time_am
    text = 'call doctor tomorrow at 9am'
    tomorrow = Date.today + 1

    result = parse_and_assert(text, 'call doctor', tomorrow)

    assert_equal 9, result.time.hour
    assert_equal 0, result.time.min
    assert_equal '09:00', result.time.to_s
  end

  def test_parse_with_time_pm
    text = 'dinner today at 7pm'
    today = Date.today

    result = parse_and_assert(text, 'dinner', today)

    assert_equal 19, result.time.hour
    assert_equal 0, result.time.min
    assert_equal '19:00', result.time.to_s
  end

  def test_parse_with_time_minutes
    text = 'meeting tomorrow at 10:30'
    tomorrow = Date.today + 1

    result = parse_and_assert(text, 'meeting', tomorrow)

    assert_equal 10, result.time.hour
    assert_equal 30, result.time.min
    assert_equal '10:30', result.time.to_s
  end

  def test_parse_with_time_hours_minutes_seconds
    text = 'start recording today at 14:30:45'
    today = Date.today

    result = parse_and_assert(text, 'start recording', today)

    assert_equal 14, result.time.hour
    assert_equal 30, result.time.min
    assert_equal 45, result.time.sec
    assert_equal '14:30:45', result.time.to_s
  end

  def test_parse_with_at_symbol
    text = 'meeting tomorrow @ 10'
    tomorrow = Date.today + 1

    result = parse_and_assert(text, 'meeting', tomorrow)

    assert_equal 10, result.time.hour
    assert_equal 0, result.time.min
    assert_equal '10:00', result.time.to_s
  end

  def test_time_with_noon_pm
    text = 'lunch meeting tomorrow at 12pm'
    tomorrow = Date.today + 1

    result = parse_and_assert(text, 'lunch meeting', tomorrow)

    assert_equal 12, result.time.hour
    assert_equal 0, result.time.min
    assert_equal '12:00', result.time.to_s
  end

  def test_time_with_midnight_am
    text = 'airport pickup today at 12am'
    today = Date.today

    result = parse_and_assert(text, 'airport pickup', today)

    assert_equal 0, result.time.hour
    assert_equal 0, result.time.min
    assert_equal '00:00', result.time.to_s
  end
end

# Testy pre datetime metódu a slovne zadaný čas (noon, midnight, ráno, večer)
class DateTimeParserTest < BaseParserTest
  def test_datetime_method
    text = 'meeting tomorrow at 10:30'
    tomorrow = Date.today + 1

    result = parse_and_assert(text, 'meeting', tomorrow)

    assert_equal 10, result.time.hour
    assert_equal 30, result.time.min

    assert_datetime_equals(tomorrow, 10, 30, result.datetime)
  end

  def assert_datetime_equals(expected_date, hour, min, datetime)
    assert_equal expected_date.year, datetime.year
    assert_equal expected_date.month, datetime.month
    assert_equal expected_date.day, datetime.day
    assert_equal hour, datetime.hour
    assert_equal min, datetime.min
  end

  def test_datetime_with_no_time_returns_nil
    text = 'meeting tomorrow'

    result = parse_and_assert(text, 'meeting', Date.today + 1)

    assert_nil result.datetime
  end

  def test_parse_with_noon
    text = 'meeting tomorrow at noon'
    tomorrow = Date.today + 1

    result = parse_and_assert(text, 'meeting', tomorrow)

    assert_equal 12, result.time.hour
    assert_equal 0, result.time.min
    assert_equal '12:00', result.time.to_s
  end

  def test_parse_with_midnight
    text = 'flight today at midnight'
    today = Date.today

    result = parse_and_assert(text, 'flight', today)

    assert_equal 0, result.time.hour
    assert_equal 0, result.time.min
    assert_equal '00:00', result.time.to_s
  end

  def test_parse_with_morning
    text = 'team meeting tomorrow in the morning'
    tomorrow = Date.today + 1

    result = parse_and_assert(text, 'team meeting', tomorrow)

    assert_equal 8, result.time.hour
    assert_equal 0, result.time.min
    assert_equal '08:00', result.time.to_s
  end

  def test_parse_with_evening
    text = 'dinner today in the evening'
    today = Date.today

    result = parse_and_assert(text, 'dinner', today)

    assert_equal 20, result.time.hour
    assert_equal 0, result.time.min
    assert_equal '20:00', result.time.to_s
  end
end

# Testy pre konfiguráciu
class ConfigParserTest < BaseParserTest
  def with_temp_config(setting, value)
    original_config = Hizuke.configuration.send(setting)
    Hizuke.configure { |config| config.send("#{setting}=", value) }
    yield
  ensure
    # Restore the original configuration
    Hizuke.configure { |config| config.send("#{setting}=", original_config) }
  end

  def test_configure_morning_time
    with_temp_config(:morning_time, { hour: 9, min: 30 }) do
      text = 'breakfast tomorrow in the morning'
      tomorrow = Date.today + 1

      result = parse_and_assert(text, 'breakfast', tomorrow)

      assert_equal 9, result.time.hour
      assert_equal 30, result.time.min
      assert_equal '09:30', result.time.to_s
    end
  end

  def test_configure_evening_time
    with_temp_config(:evening_time, { hour: 19, min: 0 }) do
      text = 'dinner today in the evening'
      today = Date.today

      result = parse_and_assert(text, 'dinner', today)

      assert_equal 19, result.time.hour
      assert_equal 0, result.time.min
      assert_equal '19:00', result.time.to_s
    end
  end
end
