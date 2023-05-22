Sure, here's a draft for the README.md:

markdown
Copy code

# Google Bard

[![BardAPI](https://img.shields.io/badge/pypi-BardAPI-black)](https://pypi.org/project/BardAPI/)

Google Bard is a Ruby gem adaptation of the Python package [BardAPI](https://github.com/dsdanielpark/BardAPI). This Python package is using reverse engineering to access Bard in an unofficial way, allowing developers to generate text completions with an API.

## Demo

I actually made this gem as wanted Bard for my latest project: a WhastsApp bot supercharged with AI. Check it out here: [ciel.chat](https://ciel.chat)

## Disclamer

This gem is exploiting reverse engineering for Bard, and it might fail in the future due to Google's code evolutions. Not sure yet wether I will maintain it or change into the official API when it's live. Feel free to contribute.

## Installation

You can install the gem by adding it to your Gemfile:

```ruby
gem 'google_bard'
```

Then run:

```ruby
bundle install
```

Or install it yourself:

```ruby
gem install google_bard
```

### Authentication

1. Visit https://bard.google.com/
2. `F12` for console
3. Session: Application → Cookies → Copy the value of `__Secure-1PSID` cookie.
   -> This is your token.

### Usage

First, require the gem in your code:

```ruby
require 'google_bard'
```

Initialize the Bard object:

```ruby
bard = GoogleBard.new(token, timeout, proxies)
```

Parameters:

- token (required): Your \_\_Secure-1PSID value from Google Bard.
- timeout (optional): Timeout for the requests (default is 20 seconds).
- proxies (optional): Proxy configuration if you want to use proxies.
- Then call the completion method with your text input:

```ruby
response = bard.completion("Hello, world!")
```

The completion method returns an `OpenStruct` with the following attributes:

- success: Whether the request was successful.
- content: The generated completion.
- conversation_id: The ID of the conversation.
- response_id: The ID of the response.
- factuality_queries: The factuality queries.
- text_query: The text query.
- choices: The choices provided by the completion.

```ruby
response.success
response.content # -> completion if success, error if not
```

Contributing
Bug reports and pull requests are welcome on GitHub at github.com/username/google_bard.

License
The gem is available as open source under the terms of the MIT License.
