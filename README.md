# Hizuke

Hizuke is a simple Ruby gem that parses text containing date references like "yesterday", "today", and "tomorrow". It extracts the date and returns the clean text without the date reference.

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
```

The parser is case-insensitive and can handle date references located anywhere in the text. It also supports date references with or without spaces (e.g., "nextweek" or "next week").

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
- `this Monday`, `this Tuesday`, etc. - returns the date of the specified day in the current week
- `next Monday`, `next Tuesday`, etc. - returns the date of the specified day in the next week
- `last Monday`, `last Tuesday`, etc. - returns the date of the specified day in the previous week
- `next week` / `nextweek` - returns the date of the next Monday
- `last week` / `lastweek` - returns the date of the previous Monday
- `next month` / `nextmonth` - returns the first day of the next month
- `next year` / `nextyear` - returns the first day of the next year
- `this weekend` / `thisweekend` - returns the date of the upcoming Saturday (or today if it's already the weekend)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/yourusername/hizuke.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT). 