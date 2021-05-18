# Alain

Simple CLI command, generating [PROST!](https://github.com/danburkert/prost) / [tonic](https://github.com/hyperium/tonic) service skeleton from protobuf.  
Alain is named after a great F1 driver.


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'alain'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install alain


## Usage

Specify proto file to `alain` command. You may need to prefix `bundle exec` with `bundle install`.

```bash
$ alain some.proto [> output.rs]
# dump to output.rs is just bash redirection
```

`alain` puts service skeleton code to STDOUT. See [example](./example/).


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/chumaltd/alain.
