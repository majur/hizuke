# frozen_string_literal: true

require "date"

module Hizuke
  # Result object containing the clean text and extracted date
  class Result
    attr_reader :text, :date

    def initialize(text, date)
      @text = text
      @date = date
    end
  end

  # Parser class responsible for extracting dates from text
  class Parser
    # Date keywords mapping
    DATE_KEYWORDS = {
      "yesterday" => -1,
      "today" => 0,
      "tomorrow" => 1,
      "nextweek" => :next_week,
      "next week" => :next_week,
      "nextmonth" => :next_month,
      "next month" => :next_month,
      "nextyear" => :next_year,
      "next year" => :next_year,
      "thisweekend" => :this_weekend,
      "this weekend" => :this_weekend
    }.freeze

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

      # Try to find compound date expressions (like "next week")
      compound_matches = {}
      
      DATE_KEYWORDS.keys.select { |k| k.include?(" ") }.each do |compound_key|
        if text.downcase.include?(compound_key)
          start_idx = text.downcase.index(compound_key)
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
        clean_text = text.dup
        clean_text.slice!(indices[0]..indices[1])
        clean_text = clean_text.strip
        
        return Result.new(clean_text, date)
      end

      # Split the text into words (for single-word date references)
      words = text.split

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
        raise ParseError, "No valid date reference found in '#{text}'"
      end

      # Calculate the date based on the keyword
      date = calculate_date(date_value)

      # Create the clean text by removing the date keyword
      clean_words = words.dup
      clean_words.delete_at(date_word_index)
      clean_text = clean_words.join(" ").strip

      Result.new(clean_text, date)
    end

    private

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
      elsif date_value == :next_month
        # Return the first day of the next month
        next_month = Date.today >> 1
        Date.new(next_month.year, next_month.month, 1)
      elsif date_value == :next_year
        # Return the first day of the next year
        next_year = Date.today.year + 1
        Date.new(next_year, 1, 1)
      elsif date_value == :this_weekend
        # Calculate days until Saturday
        days_until_saturday = (6 - Date.today.wday) % 7
        # If today is Saturday or Sunday, we're already on the weekend
        days_until_saturday = 0 if days_until_saturday == 0 || days_until_saturday == 6
        Date.today + days_until_saturday
      end
    end
  end
end 