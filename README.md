# Hizuke

Hizuke is a simple Ruby gem that parses text containing date references like "yesterday", "today", and "tomorrow". It extracts the date and returns the clean text without the date reference. It can also recognize time references like "at 10" or "at 7pm".

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'hizuke'
```

And then execute:

```
$ bundle install
```

Or install it yourself as:

```
$ gem install hizuke
```

## Usage

```ruby
require 'hizuke'

# Parse text with tomorrow's date
result = Hizuke.parse("wash car tomorrow")
puts result.text  # => "wash car"
puts result.date  # => <Date: 2023-04-01> (represents tomorrow's date)

# Parse text with today's date
result = Hizuke.parse("buy groceries today")
puts result.text  # => "buy groceries"
puts result.date  # => <Date: 2023-03-31> (represents today's date)

# Parse text with yesterday's date
result = Hizuke.parse("call mom yesterday")
puts result.text  # => "call mom"
puts result.date  # => <Date: 2023-03-30> (represents yesterday's date)

# Parse text with next week's date
result = Hizuke.parse("team meeting next week")
puts result.text  # => "team meeting"
puts result.date  # => <Date: 2023-04-04> (represents the next Monday)

# Parse text with next month's date
result = Hizuke.parse("vacation next month")
puts result.text  # => "vacation"
puts result.date  # => <Date: 2023-05-01> (represents the first day of the next month)

# Parse text with next year's date
result = Hizuke.parse("conference next year")
puts result.text  # => "conference"
puts result.date  # => <Date: 2024-01-01> (represents the first day of the next year)

# Parse text with this weekend's date
result = Hizuke.parse("hiking this weekend")
puts result.text  # => "hiking"
puts result.date  # => <Date: 2023-04-01> (represents the next Saturday)

# Parse text with time
result = Hizuke.parse("meeting tomorrow at 10")
puts result.text  # => "meeting"
puts result.date  # => <Date: 2023-04-01> (represents tomorrow's date)
puts result.time  # => 10:00 (represents the time)
puts result.datetime  # => 2023-04-01 10:00:00 (combines date and time)

# Parse text with time including minutes
result = Hizuke.parse("call client today at 14:30")
puts result.text  # => "call client"
puts result.date  # => <Date: 2023-03-31> (represents today's date)
puts result.time  # => 14:30 (represents the time)
puts result.datetime  # => 2023-03-31 14:30:00 (combines date and time)

# Parse text with AM/PM time
result = Hizuke.parse("lunch meeting tomorrow at 12pm")
puts result.text  # => "lunch meeting"
puts result.date  # => <Date: 2023-04-01> (represents tomorrow's date)
puts result.time  # => 12:00 (represents the time, noon)
puts result.datetime  # => 2023-04-01 12:00:00 (combines date and time)

# Parse text with word-based time
result = Hizuke.parse("dinner tomorrow at noon")
puts result.text  # => "dinner"
puts result.date  # => <Date: 2023-04-01> (represents tomorrow's date)
puts result.time  # => 12:00 (represents noon)

result = Hizuke.parse("flight today at midnight")
puts result.text  # => "flight"
puts result.date  # => <Date: 2023-03-31> (represents today's date)
puts result.time  # => 00:00 (represents midnight)

result = Hizuke.parse("breakfast tomorrow in the morning")
puts result.text  # => "breakfast"
puts result.date  # => <Date: 2023-04-01> (represents tomorrow's date)
puts result.time  # => 08:00 (default morning time)

result = Hizuke.parse("dinner today in the evening")
puts result.text  # => "dinner"
puts result.date  # => <Date: 2023-03-31> (represents today's date)
puts result.time  # => 20:00 (default evening time)
```

The parser is case-insensitive and can handle date references located anywhere in the text. It also supports date references with or without spaces (e.g., "nextweek" or "next week").

## Configuration

You can configure the time values for "in the morning" and "in the evening" expressions:

```ruby
Hizuke.configure do |config|
  # Set morning time to 9:30
  config.morning_time = { hour: 9, min: 30 }
  
  # Set evening time to 7:00 PM
  config.evening_time = { hour: 19, min: 0 }
end

# Now when parsing "in the morning", it will return 9:30
result = Hizuke.parse("breakfast tomorrow in the morning")
puts result.time  # => 09:30

# And "in the evening" will return 19:00
result = Hizuke.parse("dinner today in the evening")
puts result.time  # => 19:00
```

By default, "in the morning" is set to 8:00 and "in the evening" is set to 20:00.

## Supported Date Keywords

Currently, the following English date keywords are supported:

- `yesterday` - returns yesterday's date
- `today` - returns today's date
- `tomorrow` - returns tomorrow's date
- `day after tomorrow` / `dayaftertomorrow` - returns the date two days from today
- `day before yesterday` / `daybeforeyesterday` - returns the date two days before today
- `in X days` - returns the date X days from today (where X is any number)
- `X days ago` - returns the date X days before today (where X is any number)
- `in X weeks` - returns the date X weeks from today (where X is any number)
- `X weeks ago` - returns the date X weeks before today (where X is any number)
- `in X months` - returns the date X months from today (where X is any number)
- `X months ago` - returns the date X months before today (where X is any number)
- `in X years` - returns the date X years from today (where X is any number)
- `X years ago` - returns the date X years before today (where X is any number)
- `this Monday`, `this Tuesday`, etc. - returns the date of the specified day in the current week
- `next Monday`, `next Tuesday`, etc. - returns the date of the specified day in the next week
- `last Monday`, `last Tuesday`, etc. - returns the date of the specified day in the previous week
- `next week` / `nextweek` - returns the date of the next Monday
- `last week` / `lastweek` - returns the date of the previous Monday
- `next month` / `nextmonth` - returns the first day of the next month
- `last month` / `lastmonth` - returns the first day of the previous month
- `next year` / `nextyear` - returns the first day of the next year
- `last year` / `lastyear` - returns the first day of the previous year
- `this weekend` / `thisweekend` - returns the date of the upcoming Saturday (or today if it's already the weekend)
- `end of week` / `endofweek` - returns the date of the upcoming Sunday (end of week)
- `end of month` / `endofmonth` - returns the date of the last day of the current month
- `end of year` / `endofyear` - returns the date of December 31st of the current year
- `mid week` / `midweek` - returns the date of Wednesday of the current week
- `mid month` / `midmonth` - returns the date of the 15th day of the current month
- `next quarter` / `nextquarter` - returns the first day of the next quarter
- `last quarter` / `lastquarter` - returns the first day of the last quarter

## Supported Time Formats

The following time formats are supported:

### Numeric time formats
- `at X` - where X is a number (e.g., "at 10" for 10:00)
- `@ X` - alternative syntax with @ symbol
- `at X:Y` - where X is hours and Y is minutes (e.g., "at 10:30")
- `at X:Y:Z` - where X is hours, Y is minutes, and Z is seconds
- `at Xam/pm` - with AM/PM indicator (e.g., "at 10am", "at 7pm")
- `at X:Yam/pm` - with minutes and AM/PM indicator (e.g., "at 10:30am")

### Word-based time formats
- `at noon` - returns 12:00
- `at midnight` - returns 00:00
- `in the morning` - returns configurable time (default 08:00)
- `in the evening` - returns configurable time (default 20:00)

When time is included, you can access it through the `time` attribute of the result. The time is displayed in the format "HH:MM" or "HH:MM:SS" if seconds are present. Additionally, you can use the `datetime` attribute to get a Time object combining both the date and time information.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/majur/hizuke.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT). 