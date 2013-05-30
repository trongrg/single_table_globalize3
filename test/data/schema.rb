ActiveRecord::Migration.verbose = false

ActiveRecord::Schema.define do
  create_table :translations, :force => true do |t|
    t.string     :locale
    t.references :translatable
    t.string     :translatable_type
    t.string     :attribute_name
    t.string     :value
  end

  create_table :blogs, :force => true do |t|
    t.string   :description
  end

  create_table :posts, :force => true do |t|
    t.references :blog
    t.boolean    :published
  end

  create_table :globalize_translations, :force => true do |t|
    t.string     :locale
    t.references :translatable
    t.string     :translatable_type
    t.string     :attribute_name
    t.string     :value
  end

  create_table :parents, :force => true do |t|
  end

  create_table :comments, :force => true do |t|
    t.references :post
  end

  create_table :migrateds, :force => true do |t|
    t.string :name
    t.string :untranslated
  end

  create_table :two_attributes_migrateds, :force => true do |t|
    t.string :name
    t.string :untranslated
  end

  create_table :untranslateds, :force => true do |t|
    t.string :name
  end
  create_table :two_attributes_untranslateds, :force => true do |t|
    t.string :name
    t.string :body
  end

  create_table :validatees, :force => true do |t|
  end

  create_table :nested_validatees, :force => true do |t|
  end

  create_table :users, :force => true do |t|
    t.string   :email
    t.datetime :created_at
  end

  create_table :tasks, :force => true do |t|
    t.string   :name
    t.datetime :created_at
  end

  create_table :words, :force => true do |t|
    t.string :term
    t.text   :definition
    t.string :locale
  end

  create_table "versions", :force => true do |t|
    t.string   "item_type",  :null => false
    t.integer  "item_id",    :null => false
    t.string   "event",      :null => false
    t.string   "whodunnit"
    t.text     "object"
    t.string   "locale"
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], :name => "index_versions_on_item_type_and_item_id"

  create_table 'UPPERCASE_TABLE_NAME', :force => true do |t|
    t.string :name
  end

  create_table :news, :force => true do |t|
    t.string :title
  end

  create_table :pages, :force => true do |t|
  end

  create_table :serialized_attrs, :force => true do |t|
    t.text       :meta
  end

  create_table :serialized_hashes, :force => true do |t|
    t.text       :meta
  end

  create_table :accounts, :force => true do |t|
    t.string     :business_name,  :null => false, :default => ""
    t.string     :notes, :null => false, :default => ""
  end

  create_table :medias, :force => true do |t|
  end

  create_table :bazs, :force => true do |t|
  end

  create_table :model_with_custom_table_names, :force => true do |t|
    t.string  :name
  end

  create_table :mctn_translations, :force => true do |t|
    t.references :model_with_custom_table_name
    t.string :locale
    t.string :name
  end

  create_table :locales, :force => true do |t|
  end

  create_table :locale_translations, :force => true do |t|
    t.integer :locale_id
    t.string  :locale
    t.string  :name
  end
end
