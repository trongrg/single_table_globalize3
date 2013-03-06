require File.expand_path('../../test_helper', __FILE__)

class TranslationClassTest < Test::Unit::TestCase
  test 'translation_class returns the Translation class' do
    assert_equal SingleTableGlobalize3::ActiveRecord::Translation, Post.translation_class
  end

  test 'defines a belongs_to association' do
    assert_belongs_to SingleTableGlobalize3::ActiveRecord::Translation, :translatable
  end

  test 'defines a reader for :locale that returns a symbol' do
    post = SingleTableGlobalize3::ActiveRecord::Translation.new
    post.send(:write_attribute, 'locale', 'de')
    assert_equal :de, post.locale
  end

  test 'defines a write for :locale that writes a string' do
    post = SingleTableGlobalize3::ActiveRecord::Translation.new
    post.locale = :de
    assert_equal 'de', post.read_attribute('locale')
  end

  test "can create a translation class for a namespaced model" do
    assert_nothing_raised do
      module Foo
        module Bar
          class Baz < ActiveRecord::Base
            translates :bumm
          end
        end
      end
    end
  end

  test "can create a translation class for a model with an uppercase table name" do
    assert_nothing_raised do
      UppercaseTableName.create
    end
  end

  test "can create a translation class for model with custom table name" do
    assert_nothing_raised do
      NewsItem.create
    end
  end

  test "does not override existing translation class" do
    assert GlobalizeTranslation.new.respond_to?(:existing_method)
  end

  test "required_attributes returns required attributes (i.e. validates_presence_of)" do
    assert_equal [:name, :email], User.required_attributes
  end

  test "required_translated_attributes do not include non-translated attributes" do
    assert_equal [:name], User.required_translated_attributes
  end

  test "valid translations must have an associated (non-empty) locale" do
    assert !SingleTableGlobalize3::ActiveRecord::Translation.new.valid?
    assert !SingleTableGlobalize3::ActiveRecord::Translation.new(:locale => nil).valid?
    assert !SingleTableGlobalize3::ActiveRecord::Translation.new(:locale => '').valid?
  end

  test "valid translations must have an associated attribute_name" do
    assert !SingleTableGlobalize3::ActiveRecord::Translation.new.valid?
    assert !SingleTableGlobalize3::ActiveRecord::Translation.new(:attribute_name => nil).valid?
    assert !SingleTableGlobalize3::ActiveRecord::Translation.new(:attribute_name => '').valid?
  end
end


