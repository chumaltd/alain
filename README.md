# Alain

Simple CLI command, generating [PROST!](https://github.com/danburkert/prost) / [tonic](https://github.com/hyperium/tonic) service skeleton & server primitive from protobuf.  
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

<u>Before starting, protect your code with git. This generator modifies existing code, and requires a clean branch.</u>

Specify proto file to `alain` command. You may need to prefix `bundle exec` with `bundle install`.

```bash
# alain requires git commited rust project
$ cargo new some-project
$ cd some-project
$ git init .
$ cp somewhere/some.proto .
# If the working branch has diffs yet commited, alain will abort later.
$ git commit -am "initial commit"

# This command also overwrites main.rs / lib.rs
$ alain some.proto
No service definition yet...
Generate service definition
Overwrite main.rs
Overwrite lib.rs
Overwrite build.rs
Update Cargo.toml
Done

# Resulting files
$ ls
Cargo.toml  build.rs  src
$ ls src/
lib.rs  main.rs  some_service.rs
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/chumaltd/alain.
