require 'rails/generators/active_record'

module SingleTableGlobalize3
  class MigrationGenerator < ::ActiveRecord::Generators::Base
    source_root File.expand_path("../templates", __FILE__)
    argument :name, :type => :string, :default => "application"

    def copy_devise_migration
      migration_template "migration.rb", "db/migrate/create_globalize_translations"
    end
  end
end
