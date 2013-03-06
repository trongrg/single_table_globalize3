# encoding: utf-8

require File.expand_path('../../test_helper', __FILE__)

class AccessorsTest < Test::Unit::TestCase
  test "*_translatons methods are generated" do
    assert Post.new.respond_to?(:title_translations)
    assert Post.new.respond_to?(:title_translations=)
  end

  test "new post title_translations" do
    post = Post.new
    translations = {}
    assert_equal translations, post.title_translations
  end

  test "new post title_translations with title assigned" do
    post = Post.new(:title => 'John', :content => "content")
    translations = {:en => 'John'}.stringify_keys!
    assert_equal translations, post.title_translations

    with_locale(:de) { post.title = 'Jan' }
    translations = {:en => 'John', :de => 'Jan'}.stringify_keys!
    assert_equal translations, post.title_translations
  end

  test "created post title_translations" do
    post = Post.create(:title => 'John', :content => 'mad@max.com')
    translations = {:en => 'John'}.stringify_keys!
    assert_equal translations, post.title_translations

    with_locale(:de) { post.title = 'Jan' }
    translations = {:en => 'John', :de => 'Jan'}.stringify_keys!
    assert_equal translations, post.title_translations

    post.save
    assert_equal translations, post.title_translations

    post.reload
    assert_equal translations, post.title_translations
  end

  test "new post title_translations=" do
    post = Post.new(:title => 'Max', :content => 'mad@max.com')
    post.title_translations = {:en => 'John', :de => 'Jan', :ru => 'Иван'}
    assert_translated post, :en, :title, 'John'
    assert_translated post, :de, :title, 'Jan'
    assert_translated post, :ru, :title, 'Иван'

    post.save
    assert_translated post, :en, :title, 'John'
    assert_translated post, :de, :title, 'Jan'
    assert_translated post, :ru, :title, 'Иван'
  end

  test "created post title_translations=" do
    post = Post.create(:title => 'Max', :content => 'mad@max.com')
    post.title_translations = {:en => 'John', :de => 'Jan', :ru => 'Иван'}
    assert_translated post, :en, :title, 'John'
    assert_translated post, :de, :title, 'Jan'
    assert_translated post, :ru, :title, 'Иван'

    translations = {:en => 'John', :de => 'Jan', :ru => 'Иван'}.stringify_keys!
    assert_equal translations, post.title_translations
  end
end
