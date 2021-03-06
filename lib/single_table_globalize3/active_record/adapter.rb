module SingleTableGlobalize3
  module ActiveRecord
    class Adapter
      # The cache caches attributes that already were looked up for read access.
      # The stash keeps track of new or changed values that need to be saved.
      attr_accessor :record, :stash, :translations
      private :record=, :stash=

      delegate :translation_class, :to => :'record.class'

      def initialize(record)
        self.record = record
        self.stash = Attributes.new
      end

      def fetch_stash(locale, name)
        stash.read(locale, name)
      end

      def fetch_locales(name)
        stash.keys.inject({}) do |result, locale|
          if stash_contains?(locale, name)
            result.update(locale => fetch_stash(locale, name))
          else
            result
          end
        end
      end

      def stash_contains?(locale, name)
        stash.contains?(locale, name)
      end

      def fetch(locale, name)
        record.globalize_fallbacks(locale).each do |fallback|
          value = stash.contains?(fallback, name) ? fetch_stash(fallback, name) : fetch_attribute(fallback, name)

          unless fallbacks_for?(value)
            set_metadata(value, :locale => fallback, :requested_locale => locale)
            return value
          end
        end

        return nil
      end

      def write(locale, name, value)
        stash.write(locale, name, value)
      end

      def save_translations!
        stash.each do |locale, attrs|
          locale_str = locale.to_s
          attrs.each do |name, value|
            translation = record.translations.detect {|t| t.locale.to_s == locale_str && t.attribute_name == name } ||
              record.translations.build(:locale => locale_str, :attribute_name => name)
            translation.update_attribute(:value, value)
          end
        end

        reset
      end

      def reset
        stash.clear
      end

    protected

      def type_cast(name, value)
        if value.nil?
          nil
        elsif column = column_for_attribute(name)
          column.type_cast(value)
        else
          value
        end
      end

      def column_for_attribute(name)
        translation_class.columns_hash[name.to_s]
      end

      def unserializable_attribute?(name, column)
        column.text? && translation_class.serialized_attributes[name.to_s]
      end

      def fetch_attribute(locale, name)
        translation = record.translation_for(locale, name, false)
        return translation && translation.value
      end

      def set_metadata(object, metadata)
        object.translation_metadata.merge!(metadata) if object.respond_to?(:translation_metadata)
        object
      end

      def translation_metadata_accessor(object)
        return if obj.respond_to?(:translation_metadata)
        class << object; attr_accessor :translation_metadata end
        object.translation_metadata ||= {}
      end

      def fallbacks_for?(object)
        object.nil? || (fallbacks_for_empty_translations? && object.blank?)
      end

      def fallbacks_for_empty_translations?
        record.fallbacks_for_empty_translations
      end
    end
  end
end
