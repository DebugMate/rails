# DebugMate
Exception handling for Ruby on Rails

## Installation
Add this line to your application's Gemfile:

```ruby
gem "debugmate"
```

While the gem is not published in RubyGems, you can install from this repo directly:

```ruby
gem 'debugmate', :git => 'https://github.com/DebugMate/rails', :branch => 'main'
```

You can also clone this repo and point the path to the gem if you want to contribute or test locally:

`../debugmate` is relative to the project and the folder name is the one you decided when cloning the repo.

```ruby
gem "debugmate", :path => "../debugmate"
```

And then execute:
```bash
bundle
```

Or install it yourself as:
```bash
gem install debugmate
```

## Usage
Create `config/debugmate.yml` in your rails application and provide the following values:

```yaml
data:
  domain: http://debugmate.test
  enabled: true
  token: 9dd70ed8-f3b2-4244-890e-c4f666d108ed
```

Create `config/initializers/debugmate.rb` with the following line:

```ruby
DEBUGMATE_CONFIG = YAML.load_file("#{Rails.root}/config/debugmate.yml")
```

## Get the last executed query with the exception

To be able to get the query, you must add the following boilerplate code to the `debugmate.rb` initializer.

This is the only way to get Rails to intercept the call for the moment:

```ruby
module ActiveRecord
    class LogSubscriber < ActiveSupport::LogSubscriber
      # this allows us to call the original sql method. Ruby does copy the original method on the fly
      alias_method :original_sql, :sql

      def sql(event)
        Debugmate::ExceptionHandler.last_executed_query = event.payload[:sql] if DEBUGMATE_CONFIG['data']['enabled'] === true
        Debugmate::ExceptionHandler.last_executed_binds = event.payload[:binds] if DEBUGMATE_CONFIG['data']['enabled'] === true
        original_sql(event)
      end
    end
end
```

Edit `config/application.rb` to use Debugmate.

Add the middleware inside the Application class, ideally as the last line, following the example:

```ruby
module Blog
  class Application < Rails::Application
    # --- Here is the exiting code ---

    config.middleware.use Debugmate::ExceptionHandler
  end
end
```

You can check that your setup is correct by issuing the test command as follows:

```bash
rails debugmate:test
```

## Get the current User

As there are a lot of ways an user can be retrieved and maybe even the application has no user at all, if you want
to know the current user that caused the exception, you must provide a public method called `current_user` in your
`ApplicationController`.

This method must return a Hash with the `id, name and email`.

You can follow the example. Debugmate only needs the Hash:

```ruby
class ApplicationController < ActionController::Base

    def current_user
        # --- some logic that gets the user for your application ---

        user = {
            id: 99,
            name: "User from Rails",
            email: "user@fromrails.com"
        }
    end

end
```

## Sending exceptions manually to Debugmate

If you want to catch an exception manually, you can do so using the `Publish` class. Just pass the exception and call
`execute`

```ruby
def index
  @articles = Article.test
rescue => my_error
  begin
    Debugmate::Publish.new(my_error).execute
  end
end
```

### Sending information about the request

If you want Debugmate to register more details about the exception, just pass the request along:

```ruby
def index
  @articles = Article.test
rescue => my_error
  begin
    Debugmate::Publish.new(my_error, request).execute
  end
end
```

### Sending extra info to Debugmate

If you want to send some extra info about the exception, you can make use of the `extra_data` parameter. Debugmate will
display it in its `Context` tab.

```ruby
def index
    @articles = Article.test
  rescue => my_error
    begin
      extra = {hello: 'world'}
      Debugmate::Publish.new(my_error, request, extra).execute
    end
  end
```

## Running tests

Go to the gem folder and run bundler to install the gem dependencies locally
```bash
bundle
```

To run the available tests, go to the gem folder and execute
```bash
bundle exec rspec
```

You can get the list of passing tests with the doc format:
```bash
bundle exec rspec --format doc
```

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
