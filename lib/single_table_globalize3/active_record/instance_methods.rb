module SingleTableGlobalize3
  module ActiveRecord
    module InstanceMethods
      include AttributeReadWrite

      def globalize
        @globalize ||= Adapter.new(self)
      end

      def self.included(base)
        # Maintain Rails 3.0.x compatibility while adding Rails 3.1.x compatibility
        if base.method_defined?(:assign_attributes)
          base.class_eval %{
            def assign_attributes(attributes, options = {})
              with_given_locale(attributes) { super }
            end
          }
        else
          base.class_eval %{
            def attributes=(attributes, *args)
              with_given_locale(attributes) { super }
            end

            def update_attributes!(attributes, *args)
              with_given_locale(attributes) { super }
            end

            def update_attributes(attributes, *args)
              with_given_locale(attributes) { super }
            end
          }
        end
      end

      def set_translations(options)
        options.keys.each do |locale|
          options[locale].each do |key, value|
            raise NoMethodError.new("unknown attribute: #{key}") unless attribute_names.flatten.include?(key.to_s)
            translation = translation_for(locale, key.to_s)
            translation.value = value
            translation.save!
          end
        end
        globalize.reset
      end

      def reload(options = nil)
        translation_caches.clear
        translated_attribute_names.each { |name| @attributes.delete(name.to_s) }
        globalize.reset
        super(options)
      end

      def clone
        obj = super
        return obj unless respond_to?(:translated_attribute_names)

        obj.instance_variable_set(:@translations, nil) if new_record? # Reset the collection because of rails bug: http://pastie.org/1521874
        obj.instance_variable_set(:@globalize, nil )
        each_locale_and_translated_attribute do |locale, name|
          obj.globalize.write(locale, name, globalize.fetch(locale, name) )
        end

        return obj
      end

      def dup
        obj = super

        obj.instance_variable_set(:@translations, nil)
        obj.instance_variable_set(:@globalize, nil )
        each_locale_and_translated_attribute do |locale, name|
          obj.globalize.write(locale, name, globalize.fetch(locale, name) )
        end

        return obj
      end

      def rollback
        instance_variable_set('@globalize', previous_version.try(:globalize))
        self.version = versions.for_this_locale.last
      end

      def translation
        translations_for_locale(::SingleTableGlobalize3.locale)
      end

      def translation_for(locale, name, build_if_missing = true)
        translation_caches[locale] ||= HashWithIndifferentAccess.new
        translation_caches[locale][name] ||= (translations.detect{|t| t.locale == locale && t.attribute_name == name.to_s}) ||
          (translations.build(:locale => locale, :attribute_name => name) if build_if_missing)
      end

      def translations_for_locale(locale)
        translation_caches[locale] = if translations.loaded?
                                       translations.select{|t| t.locale.to_s == locale.to_s }
                                     else
                                       translations.with_locale(locale)
                                     end.inject(HashWithIndifferentAccess.new) do |hash, t|
                                       hash.update(t.attribute_name => t)
                                     end
      end

      def translation_caches
        @translation_caches ||= HashWithIndifferentAccess.new
      end

      def globalize_fallbacks(locale)
        SingleTableGlobalize3.fallbacks(locale)
      end

      private

      def update(*)
        I18n.with_locale(read_attribute(:locale) || I18n.default_locale) do
          super
        end
      end

      def create(*)
        I18n.with_locale(read_attribute(:locale) || I18n.default_locale) do
          super
        end
      end

      protected

      def each_locale_and_translated_attribute
        used_locales.each do |locale|
          translated_attribute_names.each do |name|
            yield locale, name
          end
        end
      end

      def used_locales
        globalize.stash.keys.concat(globalize.stash.keys).concat(translations.translated_locales).uniq
      end

      def save_translations!
        globalize.save_translations!
        translation_caches.clear
        self.locale = nil unless self.class.attribute_names.include?('locale')
      end

      def with_given_locale(attributes, &block)
        attributes.symbolize_keys! if attributes.respond_to?(:symbolize_keys!)

        locale = respond_to?(:locale=) ? attributes.try(:[], :locale) :
          attributes.try(:delete, :locale)

        if locale
          SingleTableGlobalize3.with_locale(locale, &block)
        else
          yield
        end
      end
    end
  end
end
