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
end 