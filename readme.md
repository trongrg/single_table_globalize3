# Single Table SingleTableGlobalize3 [![Build Status](https://travis-ci.org/svenfuchs/single_table_globalize3.png?branch=master)](https://travis-ci.org/svenfuchs/single_table_globalize3)

Single Table SingleTableGlobalize3 is the successor of SingleTableGlobalize3. Instead of creating multiple
tables for every model, it just creates one single table to store all translations
It is compatible with and builds on the new
[I18n API in Ruby on Rails](http://guides.rubyonrails.org/i18n.html) and adds
model translations to ActiveRecord.

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
post.title # => SingleTableGlobalize3 rocks!

I18n.locale = :vi
post.title # => Chuyển ngữ dễ dàng!
```

In order to make this work, you only need to run the generator and migration

```
rails generate globalize3:migration
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

By default, globalize3 will only use fallbacks when your translation model does
not exist or the translation value for the item you've requested is `nil`.
However it is possible to also use fallbacks for `blank` translations by adding
`:fallbacks_for_empty_translations => true` to the `translates` method.

```ruby
class Post < ActiveRecord::Base
  translates :title, :name
end

puts post.translations.inspect
# => [#<Post::Translation id: 1, post_id: 1, locale: "en", title: "SingleTableGlobalize3 rocks!", name: "SingleTableGlobalize3">,
      #<Post::Translation id: 2, post_id: 1, locale: "nl", title: '', name: nil>]

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

puts post.translations.inspect
# => [#<Post::Translation id: 1, post_id: 1, locale: "en", title: "SingleTableGlobalize3 rocks!", name: "SingleTableGlobalize3">,
      #<Post::Translation id: 2, post_id: 1, locale: "nl", title: '', name: nil>]

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

Globalize.fallbacks = {:en => [:en, :pl], :pl => [:pl, :en]}

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
  #<Post::Translation id: 1, post_id: 1, locale: "en", title: "SingleTableGlobalize3 rocks!", name: "SingleTableGlobalize3">,
  #<Post::Translation id: 2, post_id: 1, locale: "nl", title: '', name: nil>
]

Post.with_translations(I18n.locale)
# => [
  #<Post::Translation id: 1, post_id: 1, locale: "en", title: "SingleTableGlobalize3 rocks!", name: "SingleTableGlobalize3">,
  #<Post::Translation id: 2, post_id: 1, locale: "nl", title: '', name: nil>
]

Post.with_translations('de')
# => []
```

## Changes since SingleTableGlobalize3

* Single table with polymorphic association
* Removed versioning (temporary)

## Changes since Globalize2

* `translation_table_name` was renamed to `translations_table_name`
* `available_locales` has been removed. please use `translated_locales`

## Migration from Globalize for Rails (version 1)

See this script by Tomasz Stachewicz: http://gist.github.com/120867

## Alternative Solutions

* [Veger's fork](http://github.com/veger/globalize2) - uses default AR schema for the default locale, delegates to the translations table for other locales only
* [TranslatableColumns](http://github.com/iain/translatable_columns) - have multiple languages of the same attribute in a model (Iain Hecker)
* [Traco](https://github.com/barsoom/traco) - A newer take on using multiple columns in the same model (Barsoom)
* [localized_record](http://github.com/glennpow/localized_record) - allows records to have localized attributes without any modifications to the database (Glenn Powell)
* [model_translations](http://github.com/janne/model_translations) - Minimal implementation of Globalize2 style model translations (Jan Andersson)

## Related solutions

* [globalize2_versioning](http://github.com/joshmh/globalize2_versioning) - acts_as_versioned style versioning for globalize2 (Joshua Harvey)
* [i18n_multi_locales_validations](http://github.com/ZenCocoon/i18n_multi_locales_validations) - multi-locales attributes validations to validates attributes from globalize2 translations models (Sébastien Grosjean)
* [globalize2 Demo App](http://github.com/svenfuchs/globalize2-demo) - demo application for globalize2 (Sven Fuchs)
* [migrate_from_globalize1](http://gist.github.com/120867) - migrate model translations from Globalize1 to globalize2 (Tomasz Stachewicz)
* [easy_globalize2_accessors](http://github.com/astropanic/easy_globalize2_accessors) - easily access (read and write) globalize2-translated fields (astropanic, Tomasz Stachewicz)
* [globalize2-easy-translate](http://github.com/bsamman/globalize2-easy-translate) - adds methods to easily access or set translated attributes to your model (bsamman)
* [batch_translations](http://github.com/rilla/batch_translations) - allow saving multiple globalize2 translations in the same request (Jose Alvarez Rilla)
