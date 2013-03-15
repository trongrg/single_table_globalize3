class AddLocaleColumnToVersions < ActiveRecord::Migration
  def up
    add_column :versions, :locale, :string
  end

  def down
    remove_column :versions, :locale
  end
end
