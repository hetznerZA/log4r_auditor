# Log4rAuditor

This gem provides the log4r auditor that can be plugged into the SOAR architecture.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'log4r_auditor'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install log4r_auditor

## Testing

Behavioural driven testing can be performed by testing so:

    $ bundle exec rspec -cfd spec/*

## Usage

Initialize and configure the auditor so:

```ruby
@iut = Log4rAuditor::Log4rAuditor.new
@log4r_configuration = { 'file_name' => 'logfile',
                         'standard_stream' => 'stdout' }
@iut.configure(@log4r_configuration)
```

Audit using the API methods inherited from SoarAuditorApi::AuditorAPI, e.g.:

```ruby
@iut.warn("This is a test event")
```

## Detailed example

```ruby
require 'log4r_auditor'
require 'soar_auditing_format'
require 'time'
require 'securerandom'

class Main
  def test_sanity
    @iut = Log4rAuditor::Log4rAuditor.new
    @log4r_configuration =
    { }
    @iut.configure(@log4r_configuration)
    @iut.set_audit_level(:debug)

    my_optional_operation_field = SoarAuditingFormatter::Formatter.optional_field_format("operation", "Http.Get")
    my_optional_method_name_field = SoarAuditingFormatter::Formatter.optional_field_format("method", "#{self.class}::#{__method__}::#{__LINE__}")
    @iut.debug(SoarAuditingFormatter::Formatter.format(:debug,'my-sanity-service-id',SecureRandom.hex(32),Time.now.iso8601(3),"#{my_optional_method_name_field}#{my_optional_operation_field} test message with optional fields"))
  end
end

main = Main.new
main.test_sanity
```

## Contributing

Bug reports and feature requests are welcome by email to barney dot de dot villiers at hetzner dot co dot za. This gem is sponsored by Hetzner (Pty) Ltd (http://hetzner.co.za)

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
