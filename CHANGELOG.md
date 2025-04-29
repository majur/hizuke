# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.0.4] - 2023-06-15

### Added
- Support for time recognition in text:
  - "at X" format (e.g., "at 10" for 10:00)
  - "@ X" alternative syntax
  - Time with minutes "at X:Y" (e.g., "at 10:30")
  - Time with seconds "at X:Y:Z" (e.g., "at 10:30:45")
  - AM/PM format "at Xam/pm" (e.g., "at 10am", "at 7pm")
- New attributes in Result class:
  - `time` attribute to access the extracted time
  - `datetime` method to get a combined Time object of date and time
- Created a dedicated `TimeOfDay` class for better time handling with cleaner display
- Support for word-based time expressions:
  - "at noon" - returns 12:00
  - "at midnight" - returns 00:00
  - "in the morning" - returns configurable time (default 08:00)
  - "in the evening" - returns configurable time (default 20:00)
- Configuration system to customize times for "morning" and "evening"
- Comprehensive tests for time parsing functionality
- Updated documentation with time parsing examples and supported formats

## [0.0.3] - 2023-05-09

### Added
- Support for quarterly date references:
  - "next quarter" / "nextquarter" - returns the first day of the next quarter
  - "last quarter" / "lastquarter" - returns the first day of the last quarter
- Support for relative day references:
  - "day after tomorrow" / "dayaftertomorrow"
  - "day before yesterday" / "daybeforeyesterday"
- Support for dynamic time spans:
  - "in X days", "X days ago"
  - "in X weeks", "X weeks ago"
  - "in X months", "X months ago"
  - "in X years", "X years ago"
- Support for specific days of the week:
  - "this Monday", "this Tuesday", etc.
  - "next Monday", "next Tuesday", etc.
  - "last Monday", "last Tuesday", etc.
- Support for additional time references:
  - "last week" / "lastweek"
  - "last month" / "lastmonth"
  - "last year" / "lastyear"
  - "end of week" / "endofweek"
  - "end of month" / "endofmonth" 
  - "end of year" / "endofyear"
  - "mid week" / "midweek"
  - "mid month" / "midmonth"
- Updated documentation to reflect all new functionality

## [0.0.2] - 2025-04-23

### Added
- Support for additional date keywords:
  - "next week" / "nextweek"
  - "next month" / "nextmonth"
  - "next year" / "nextyear"
  - "this weekend" / "thisweekend"
- Enhanced parsing to support compound date expressions with spaces

## [0.0.1] - 2025-04-12

### Added
- Initial release
- Basic date parsing functionality
- Support for "yesterday", "today", and "tomorrow" keywords
- Tests using Minitest 