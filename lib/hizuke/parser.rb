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
      "tomorrow" => 1
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

      # Split the text into words
      words = text.split

      # Find the first date keyword
      date_word_index = nil
      date_offset = nil

      words.each_with_index do |word, index|
        clean_word = word.downcase.gsub(/[^a-z]/, '')
        if DATE_KEYWORDS.key?(clean_word)
          date_word_index = index
          date_offset = DATE_KEYWORDS[clean_word]
          break
        end
      end

      if date_word_index.nil?
        raise ParseError, "No valid date reference found in '#{text}'"
      end

      # Calculate the date based on the keyword
      date = Date.today + date_offset

      # Create the clean text by removing the date keyword
      clean_words = words.dup
      clean_words.delete_at(date_word_index)
      clean_text = clean_words.join(" ").strip

      Result.new(clean_text, date)
    end
  end
end 