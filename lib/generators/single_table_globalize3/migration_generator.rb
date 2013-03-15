require 'rails/generators/active_record'

module SingleTableGlobalize3
  class MigrationGenerator < ::ActiveRecord::Generators::Base
    source_root File.expand_path("../templates", __FILE__)
    argument :name, :type => :string, :default => "application"
    class_option :with_versioning, :type => :boolean, :default => false, :desc => "Generate migration for versioning"

    def create_migration_file
      migration_template "migration.rb", "db/migrate/create_globalize_translations"
      generate "paper_trail:install #{"--force" if options.force?}" if options.with_versioning?
      migration_template "add_locale_column_to_versions.rb", "db/migrate/add_locale_column_to_versions" if options.with_versioning?
    end
  end
end
