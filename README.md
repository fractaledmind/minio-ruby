# minio-ruby

[MinIO](https://min.io) is an open-source S3-compatible object store. This gem provides a Ruby interface to MinIO.

<p>
  <a href="https://rubygems.org/gems/minio">
  <img alt="GEM Version" src="https://img.shields.io/gem/v/minio?color=168AFE&include_prereleases&logo=ruby&logoColor=FE1616">
  </a>
  <a href="https://rubygems.org/gems/minio">
    <img alt="GEM Downloads" src="https://img.shields.io/gem/dt/minio?color=168AFE&logo=ruby&logoColor=FE1616">
  </a>
  <a href="https://github.com/testdouble/standard">
    <img alt="Ruby Style" src="https://img.shields.io/badge/style-standard-168AFE?logo=ruby&logoColor=FE1616" />
  </a>
  <a href="https://github.com/fractaledmind/minio-ruby/actions/workflows/main.yml">
    <img alt="Tests" src="https://github.com/fractaledmind/minio-ruby/actions/workflows/main.yml/badge.svg" />
  </a>
  <a href="https://github.com/sponsors/fractaledmind">
    <img alt="Sponsors" src="https://img.shields.io/github/sponsors/fractaledmind?color=eb4aaa&logo=GitHub%20Sponsors" />
  </a>
  <a href="https://ruby.social/@fractaledmind">
    <img alt="Ruby.Social Follow" src="https://img.shields.io/mastodon/follow/109291299520066427?domain=https%3A%2F%2Fruby.social&label=%40fractaledmind&style=social">
  </a>
  <a href="https://twitter.com/fractaledmind">
    <img alt="Twitter Follow" src="https://img.shields.io/twitter/url?label=%40fractaledmind&style=social&url=https%3A%2F%2Ftwitter.com%2Ffractaledmind">
  </a>
</p>

## Installation

Install the gem and add to the application's Gemfile by executing:

```sh
bundle add minio
```

If bundler is not being used to manage dependencies, install the gem by executing:

```sh
gem install minio
```

### Using a local installation of `minio`

If you are not able to use the vendored standalone executables (for example, if you're on an unsupported platform), you can use a local installation of the `minio` executable by setting an environment variable named `MINIO_INSTALL_DIR` to the directory containing the executable.

For example, if you've installed `minio` so that the executable is found at `/usr/local/bin/minio`, then you should set your environment variable like so:

``` sh
MINIO_INSTALL_DIR=/usr/local/bin
```

This also works with relative paths. If you've installed into your app's directory at `./.bin/minio`:

``` sh
MINIO_INSTALL_DIR=.bin
```

## Usage

### Configuration

You can configure (if needed, this is optional) the `username` and `password` to secure the MinIO web dashboard. This Ruby interface permits you to use any method of storing secrets that you prefer. For example, you could store these secrets in Rails' encrypted credentials:

```ruby
# config/initializers/minio.rb
minio_credentials = Rails.application.credentials.minio
Litestream.configure do |config|
  config.username = minio_credentials.username
  config.password = minio_credentials.password
end
```

The default credentials that MinIO uses are `minioadmin` for both the username and password. If you are using the default credentials, you do not need to configure the `username` and `password` in the initializer, but you should absolutely change the default credentials in a production environment.

If you want, you can also configure the username and password via environment variables:

```sh
export MINIO_ROOT_USER=frodo
export MINIO_ROOT_PASSWORD=ikeptmysecrets
```

### Running the server

You can start the MinIO server via the gem's rake task:

```sh
bin/rails minio:server
# or
bundle exec rake minio:server
```

If you need to pass arguments through the rake task to the underlying `minio` command, that can be done with argument forwarding:

```sh
bin/rails minio:server -- --directory /mnt/data
```

This example shows the special `--directory` option available on [the `server` command](https://min.io/docs/minio/linux/reference/minio-server/minio-server.html), which allows you to specify the directory where MinIO will store its data. By default, the gem will use the `storage/minio` directory in your Rails app.

The MinIO `server` command supports various additional options, which can be passed through the rake task:

```sh
--config value               specify server configuration via YAML configuration [$MINIO_CONFIG]
--address value              bind to a specific ADDRESS:PORT, ADDRESS can be an IP or hostname (default: ":9000") [$MINIO_ADDRESS]
--console-address value      bind to a specific ADDRESS:PORT for embedded Console UI, ADDRESS can be an IP or hostname [$MINIO_CONSOLE_ADDRESS]
--ftp value                  enable and configure an FTP(Secure) server
--sftp value                 enable and configure an SFTP server
--certs-dir value, -S value  path to certs directory (default: "~/.minio/certs")
--quiet                      disable startup and info messages
--anonymous                  hide sensitive information from logging
--json                       output logs in JSON format
--help, -h                   show help
```

## Troubleshooting

Some common problems experienced by users ...

### `ERROR: Cannot find the minio executable` for supported platform

Some users are reporting this error even when running on one of the supported native platforms:

* arm64-darwin (darwin-arm64)
* arm64-linux (linux-arm64)
* x86_64-darwin (darwin-amd64)
* x86_64-linux (linux-amd64)
* x86_64-windows (windows-amd64)

#### Check Bundler PLATFORMS

A possible cause of this is that Bundler has not been told to include native gems for your current platform. Please check your `Gemfile.lock` file to see whether your native platform is included in the `PLATFORMS` section. If necessary, run:

``` sh
bundle lock --add-platform <platform-name>
```

and re-bundle.

#### Check BUNDLE_FORCE_RUBY_PLATFORM

Another common cause of this is that Bundler is configured to always use the "ruby" platform via the `BUNDLE_FORCE_RUBY_PLATFORM` config parameter being set to `true`. Please remove this configuration:

``` sh
bundle config unset force_ruby_platform
# or
bundle config set --local force_ruby_platform false
```

and re-bundle.

See https://bundler.io/man/bundle-config.1.html for more information.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. For maintainers, to release a new version, run `bin/release $VERSION`, which will create a git tag for the version, push git commits and tags, and push all of the platform-specific `.gem` files to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/fractaledmind/minio-ruby. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/fractaledmind/minio-ruby/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Sqlpkg::Ruby project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/fractaledmind/minio-ruby/blob/main/CODE_OF_CONDUCT.md).
