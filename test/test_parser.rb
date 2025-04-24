# frozen_string_literal: true

require "test_helper"

class TestParser < Minitest::Test
  def test_parse_tomorrow
    text = "wash car tomorrow"
    tomorrow = Date.today + 1
    
    result = Hizuke::Parser.parse(text)
    
    assert_equal "wash car", result.text
    assert_equal tomorrow, result.date
  end

  def test_parse_today
    text = "buy groceries today"
    today = Date.today
    
    result = Hizuke::Parser.parse(text)
    
    assert_equal "buy groceries", result.text
    assert_equal today, result.date
  end

  def test_parse_yesterday
    text = "call mom yesterday"
    yesterday = Date.today - 1
    
    result = Hizuke::Parser.parse(text)
    
    assert_equal "call mom", result.text
    assert_equal yesterday, result.date
  end

  def test_parse_mixed_case
    text = "submit report ToDaY"
    today = Date.today
    
    result = Hizuke::Parser.parse(text)
    
    assert_equal "submit report", result.text
    assert_equal today, result.date
  end

  def test_parse_with_punctuation
    text = "finish presentation, tomorrow!"
    tomorrow = Date.today + 1
    
    result = Hizuke::Parser.parse(text)
    
    assert_equal "finish presentation,", result.text
    assert_equal tomorrow, result.date
  end

  def test_date_keyword_in_middle
    text = "discuss today project timeline"
    today = Date.today
    
    result = Hizuke::Parser.parse(text)
    
    assert_equal "discuss project timeline", result.text
    assert_equal today, result.date
  end

  def test_parse_next_week
    text = "team meeting next week"
    # Find next Monday
    days_until_monday = (1 - Date.today.wday) % 7
    # If today is Monday, we want next Monday, not today
    days_until_monday = 7 if days_until_monday == 0
    next_monday = Date.today + days_until_monday
    
    result = Hizuke::Parser.parse(text)
    
    assert_equal "team meeting", result.text
    assert_equal next_monday, result.date
  end

  def test_parse_next_month
    text = "vacation next month"
    # Get first day of next month
    next_month = Date.today >> 1
    next_month_first_day = Date.new(next_month.year, next_month.month, 1)
    
    result = Hizuke::Parser.parse(text)
    
    assert_equal "vacation", result.text
    assert_equal next_month_first_day, result.date
  end

  def test_parse_next_year
    text = "conference next year"
    # Get first day of next year
    next_year_first_day = Date.new(Date.today.year + 1, 1, 1)
    
    result = Hizuke::Parser.parse(text)
    
    assert_equal "conference", result.text
    assert_equal next_year_first_day, result.date
  end

  def test_parse_this_weekend
    text = "hiking this weekend"
    # Calculate expected date (Saturday)
    days_until_saturday = (6 - Date.today.wday) % 7
    # If today is Saturday or Sunday, we're already on the weekend
    days_until_saturday = 0 if days_until_saturday == 0 || days_until_saturday == 6
    expected_date = Date.today + days_until_saturday
    
    result = Hizuke::Parser.parse(text)
    
    assert_equal "hiking", result.text
    assert_equal expected_date, result.date
  end

  def test_parse_without_spaces
    text = "exam nextweek"
    # Find next Monday
    days_until_monday = (1 - Date.today.wday) % 7
    # If today is Monday, we want next Monday, not today
    days_until_monday = 7 if days_until_monday == 0
    next_monday = Date.today + days_until_monday
    
    result = Hizuke::Parser.parse(text)
    
    assert_equal "exam", result.text
    assert_equal next_monday, result.date
  end

  def test_raises_on_no_date_keyword
    text = "wash car"
    
    assert_raises(Hizuke::ParseError) do
      Hizuke::Parser.parse(text)
    end
  end

  def test_raises_on_empty_input
    assert_raises(Hizuke::ParseError) do
      Hizuke::Parser.parse("")
    end
  end

  def test_raises_on_nil_input
    assert_raises(Hizuke::ParseError) do
      Hizuke::Parser.parse(nil)
    end
  end

  def test_parse_day_after_tomorrow
    text = "meeting day after tomorrow"
    day_after_tomorrow = Date.today + 2
    
    result = Hizuke::Parser.parse(text)
    
    assert_equal "meeting", result.text
    assert_equal day_after_tomorrow, result.date
  end

  def test_parse_dayaftertomorrow
    text = "dentist appointment dayaftertomorrow"
    day_after_tomorrow = Date.today + 2
    
    result = Hizuke::Parser.parse(text)
    
    assert_equal "dentist appointment", result.text
    assert_equal day_after_tomorrow, result.date
  end

  def test_parse_day_before_yesterday
    text = "call mom day before yesterday"
    day_before_yesterday = Date.today - 2
    
    result = Hizuke::Parser.parse(text)
    
    assert_equal "call mom", result.text
    assert_equal day_before_yesterday, result.date
  end

  def test_parse_daybeforeyesterday
    text = "received package daybeforeyesterday"
    day_before_yesterday = Date.today - 2
    
    result = Hizuke::Parser.parse(text)
    
    assert_equal "received package", result.text
    assert_equal day_before_yesterday, result.date
  end

  def test_parse_in_x_days
    text = "exam in 5 days"
    expected_date = Date.today + 5
    
    result = Hizuke::Parser.parse(text)
    
    assert_equal "exam", result.text
    assert_equal expected_date, result.date
  end

  def test_parse_x_days_ago
    text = "submitted report 3 days ago"
    expected_date = Date.today - 3
    
    result = Hizuke::Parser.parse(text)
    
    assert_equal "submitted report", result.text
    assert_equal expected_date, result.date
  end
end 