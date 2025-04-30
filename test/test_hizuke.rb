# frozen_string_literal: true

require 'test_helper'

class TestHizuke < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Hizuke::VERSION
  end

  def test_parse_delegates_to_parser
    text = 'wash car tomorrow'
    tomorrow = Date.today + 1

    result = Hizuke.parse(text)

    assert_equal 'wash car', result.text
    assert_equal tomorrow, result.date
  end
end
