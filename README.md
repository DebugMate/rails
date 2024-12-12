# DebugMate
Exception handling for Ruby on Rails

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'debugmate', '~> 0.1.2'
```

And then execute:
```bash
bundle install
```

Or install it yourself as:
```bash
gem install debugmate
```

## Usage
Create `config/debugmate.yml` in your rails application and provide the following values:

```yaml
data:
  domain: your-domain
  enabled: true
  token: your-token
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

To verify that your Debugmate setup is correct, follow these steps:

1. Create the Rake Task File
Add the following content to a new file called lib/tasks/debugmate_task.rake in your project

```ruby
namespace :debugmate do
  desc "Send fake data to webhook"
  task test: :environment do
    Debugmate::ExceptionHandler.send_test
  end
end
```

2. Run the Test Command
After adding the Rake task, run the following command in your terminal to test the setup:

```bash
rails debugmate:test
```

This command will send fake data to your configured webhook, allowing you to verify that Debugmate is working correctly.

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
