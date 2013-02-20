class CreateGlobalizeTranslations < ActiveRecord::Migration
  def up
    create_table :globalize_translations do |t|
      t.integer :translatable_id
      t.string :translatable_type
      t.string :locale
      t.string :attribute_name
      t.string :value
      t.timestamps
    end
    add_index :globalize_translations, [:translatable_id, :translatable_type], :name => :index_globalize_translalation_1
    add_index :globalize_translations, [:translatable_id, :translatable_type, :locale], :name => :index_globalize_translalation_2
    add_index :globalize_translations, [:translatable_id, :translatable_type, :locale, :attribute_name], :name => :index_globalize_translalation_3
  end

  def down
    remove_index :globalize_translations, :name => :index_globalize_translalation_3
    remove_index :globalize_translations, :name => :index_globalize_translalation_2
    remove_index :globalize_translations, :name => :index_globalize_translalation_1
    drop_table :globalize_translations
  end
end
