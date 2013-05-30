module SingleTableGlobalize3
  module ActiveRecord
    class Translation < ::ActiveRecord::Base
      if self.respond_to?(:table_name=)
        self.table_name = :globalize_translations
      else
        set_table_name :globalize_translations
      end

      attr_accessible :locale, :attribute_name, :value
      validates :locale, :attribute_name, :presence => true
      belongs_to :translatable, :polymorphic => true

      class << self
        def with_locales(*locales)
          # Avoid using "IN" with SQL queries when only using one locale.
          locales = locales.flatten.map(&:to_s)
          locales = locales.first if locales.one?
          where :locale => locales
        end
        alias with_locale with_locales

        def translated_locales
          select('DISTINCT locale').order(:locale).map(&:locale)
        end

        def attribute(attribute)
          attribute = attribute.to_s
          where :attribute_name => attribute
        end

        def attribute_translations(attribute)
          attribute(attribute).inject(HashWithIndifferentAccess.new) do |hash, translation|
            hash.update(translation.locale => translation.value)
          end
        end
      end

      def locale
        _locale = read_attribute :locale
        _locale.present? ? _locale.to_sym : _locale
      end

      def locale=(locale)
        write_attribute :locale, locale.to_s
      end
    end
  end
end
