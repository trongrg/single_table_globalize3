# Single Table Globalize3 [![Build Status](https://travis-ci.org/trongrg/single_table_globalize3.png?branch=master)](https://travis-ci.org/trongrg/single_table_globalize3)

Single Table Globalize3 is the successor of Globalize3. Instead of creating
tables for every model, it just creates one single table to store all translations

# Credits
* Sven Fuchs, Joshua Harvey, Clemens Kofler, John-Paul Bader, Tomasz Stachewicz, Philip Arndt and other contributors for the great globalize3 project
* My girlfriend for inspiring me to complete this

## Requirements

* ActiveRecord > 3.0.0
* I18n

## Installation

To install Single Table Globalize3 with its default setup just use:

gem install single_table_globalize3


When using bundler put it in your Gemfile:

```ruby
source 'https://rubygems.org'

gem 'single_table_globalize3'
```

## Model translations

Model translations allow you to translate your models' attribute values. E.g.

```ruby
class Post < ActiveRecord::Base
  translates :title, :text
end
```

Allows you to translate the attributes :title and :text per locale:

```ruby
I18n.locale = :en
post.title # => 'SingleTableGlobalize3 rocks!'

I18n.locale = :vi
post.title # => 'Chuyển ngữ dễ dàng!'
```

To setup, you only need to run the generator and migration

```
rails generate single_table_globalize3:migration
rake db:migrate
```

## I18n fallbacks for empty translations

It is possible to enable fallbacks for empty translations. It will depend on the
configuration setting you have set for I18n translations in your Rails config.

You can enable them by adding the next line to `config/application.rb` (or only
`config/environments/production.rb` if you only want them in production)

```ruby
config.i18n.fallbacks = true
```

By default, single_table_globalize3 will only use fallbacks when your translation model does
not exist or the translation value for the item you've requested is `nil`.
However it is possible to also use fallbacks for `blank` translations by adding
`:fallbacks_for_empty_translations => true` to the `translates` method.

```ruby
class Post < ActiveRecord::Base
  translates :title, :name
end

I18n.locale = :en
post.title # => 'SingleTableGlobalize3 rocks!'
post.name  # => 'SingleTableGlobalize3'

I18n.locale = :nl
post.title # => ''
post.name  # => 'SingleTableGlobalize3'
```

```ruby
class Post < ActiveRecord::Base
  translates :title, :name, :fallbacks_for_empty_translations => true
end

I18n.locale = :en
post.title # => 'SingleTableGlobalize3 rocks!'
post.name  # => 'SingleTableGlobalize3'

I18n.locale = :nl
post.title # => 'SingleTableGlobalize3 rocks!'
post.name  # => 'SingleTableGlobalize3'
```

## Fallback locales to each other

It is possible to setup locales to fallback to each other.

```ruby
class Post < ActiveRecord::Base
  translates :title, :name
end

SingleTableGlobalize3.fallbacks = {:en => [:en, :pl], :pl => [:pl, :en]}

I18n.locale = :en
en_post = Post.create(:title => 'en_title')

I18n.locale = :pl
pl_post = Post.create(:title => 'pl_title')
en_post.title # => 'en_title'

I18n.locale = :en
en_post.title # => 'en_title'
pl_post.title # => 'pl_title'
```


## Scoping objects by those with translations

To only return objects that have a translation for the given locale we can use
the `with_translations` scope. This will only return records that have a
translations for the passed in locale.

```ruby
Post.with_translations('en')
# => [
  #<Post:0x007faf99ba03b0> {
    :created_at => Mon, 04 Mar 2013 22:21:14 UTC +00:00,
            :id => 1,
          :name => "Cool!",
         :title => "SingleTableGlobalize3",
    :updated_at => Mon, 04 Mar 2013 22:23:52 UTC +00:00
  },
  #<Post:0x007faf95c12f68> {
    :created_at => Mon, 04 Mar 2013 22:25:10 UTC +00:00,
            :id => 2,
          :name => "Test",
         :title => "Title",
    :updated_at => Mon, 04 Mar 2013 22:25:10 UTC +00:00
  }
]

Post.with_translations(I18n.locale)
# => [
  #<Post:0x007faf99ba03b0> {
    :created_at => Mon, 04 Mar 2013 22:21:14 UTC +00:00,
            :id => 1,
          :name => "Cool!",
         :title => "SingleTableGlobalize3",
    :updated_at => Mon, 04 Mar 2013 22:23:52 UTC +00:00
  },
  #<Post:0x007faf95c12f68> {
    :created_at => Mon, 04 Mar 2013 22:25:10 UTC +00:00,
            :id => 2,
          :name => "Test",
         :title => "Title",
    :updated_at => Mon, 04 Mar 2013 22:25:10 UTC +00:00
  }
]

Post.with_translations('de')
# => []
```

## Changes since Globalize3

* Single table with polymorphic association
* Removed versioning (temporary)
