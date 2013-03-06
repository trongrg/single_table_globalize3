module SingleTableGlobalize3
  module ActiveRecord
    module WithTranslations
      delegate :translated_locales, :to => :translation_class

      def with_translations(*locales)
        index = locales.pop if locales.last.is_a?(Fixnum)
        locales = locales.concat(SingleTableGlobalize3.fallbacks).flatten.map(&:to_s)
        alias_table_name = translations_table_name(index)

        joins("LEFT OUTER JOIN #{translation_class.table_name} #{alias_table_name} ON #{alias_table_name}.translatable_id = #{table_name}.id").
        select("distinct #{table_name}.*").
        where(translated_column_name('locale', index) => locales)
      end

      def with_translated_attribute(name, value, locales = nil)
        locales ||= SingleTableGlobalize3.fallbacks
        self.join_index = self.join_index + 1
        with_translations(locales, self.join_index).where(
          translated_column_name('attribute_name', self.join_index) => name.to_s,
          translated_column_name('value', self.join_index) => Array(value).map(&:to_s)
        )
      end

      def translated?(name)
        translated_attribute_names.include?(name.to_sym)
      end

      def required_attributes
        validators.map { |v| v.attributes if v.is_a?(ActiveModel::Validations::PresenceValidator) }.flatten
      end

      def required_translated_attributes
        translated_attribute_names & required_attributes
      end

      def translation_class
        SingleTableGlobalize3::ActiveRecord::Translation
      end

      def translations_table_name(index = nil)
        "#{translation_class.table_name}#{index}"
      end

      def translated_column_name(name, index = nil)
        "#{translations_table_name(index)}.#{name}"
      end
      protected
      def join_index
        @join_index = 0 if @join_index.nil? || @join_index > 100
        @join_index
      end

      def join_index=(value)
        @join_index = value
      end
    end
  end
end
