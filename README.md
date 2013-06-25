# Spree Klarna Invoice

[![Build Status](https://secure.travis-ci.org/futhr/spree_klarna_invoice.png?branch=master)](http://travis-ci.org/futhr/spree_klarna_invoice)
[![Dependency Status](https://gemnasium.com/futhr/spree_klarna_invoice.png)](https://gemnasium.com/futhr/spree_klarna_invoice)
[![Coverage Status](https://coveralls.io/repos/futhr/spree_klarna_invoice/badge.png?branch=master)](https://coveralls.io/r/futhr/spree_klarna_invoice)

Spree extenstion for Klarna Invoice Payment Method. Makes it possible to invoice customers with Klarna's services. Read more on [Klara][1].

Based on Klarna-ruby it is using the old Klarna API. There is a newer version and I intend to fork klarna-ruby and update it with the [Klarna API 2.0][2].

## Requirements

* Based on *[klarna-ruby][3]* library

## Installation

In your Gemfile:

```ruby
gem 'spree_klarna_invoice', github: 'futhr/spree_klarna_invoice'
```

Then run from the command line:

    $ bundle install
    $ rails g spree_klarna_invoice:install
    $ rake db:migrate

## Todo

__High Prio__

* Refactor for Spree 2.0
* Write tests
* Update klarna-ruby for [Klarna API 2.0][2]

__Completed__

* ~~Auto capture~~
* ~~Send invoice via email~~
* ~~Send invoice via mail~~
* ~~Production mode testing~~

## Contributing

In the spirit of [free software][4], **everyone** is encouraged to help improve this project.

Here are some ways *you* can contribute:

* by using prerelease versions
* by reporting [bugs][5]
* by suggesting new features
* by writing or editing documentation
* by writing specifications
* by writing code (*no patch is too small*: fix typos, add comments, clean up inconsistent whitespace)
* by refactoring code
* by resolving [issues][5]
* by reviewing patches

Starting point:

* Fork the repo
* Clone your repo
* Run `bundle`
* Run `bundle exec rake test_app` to create the test application in `spec/test_app`
* Make your changes and follow this [Style Guide](https://github.com/thoughtbot/guides)
* Ensure specs pass by running `bundle exec rspec spec`
* Submit your pull request

Copyright (c) 2013 Emil Karlsson, released under the [New BSD License][6]

[1]: http://klarna.com
[2]: https://docs.klarna.com/en/rest-api
[3]: https://github.com/futhr/klarna-ruby
[4]: http://www.fsf.org/licensing/essays/free-sw.html
[5]: https://github.com/futhr/spree_klarna_invoice/issues
[6]: https://github.com/futhr/spree_klarna_invoice/tree/master/LICENSE

