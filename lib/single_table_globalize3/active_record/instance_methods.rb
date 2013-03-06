module SingleTableGlobalize3
  module ActiveRecord
    module InstanceMethods
      delegate :translated_locales, :to => :translations

      def globalize
        @globalize ||= Adapter.new(self)
      end

      def attributes
        super.merge(translated_attributes)
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

      # Deprecate old use of locale
      def deprecated_options(options)
        unless options.is_a?(Hash)
          warn "[DEPRECATION] passing 'locale' as #{options.inspect} is deprecated. Please use {:locale => #{options.inspect}} instead."
          {:locale => options}
        else
          options
        end
      end

      def write_attribute(name, value, options = {})
        if translated?(name)
          options = {:locale => SingleTableGlobalize3.locale}.merge(deprecated_options(options))

          # Dirty tracking, paraphrased from
          # ActiveRecord::AttributeMethods::Dirty#write_attribute.
          name_str = name.to_s
          # If there's already a change, delete it if this undoes the change.
          if attribute_changed?(name_str) && value == changed_attributes[name_str]
            changed_attributes.delete(name_str)
          elsif !attribute_changed?(name_str) && value != (old = globalize.fetch(options[:locale], name))
            changed_attributes[name_str] = old
          end

          globalize.write(options[:locale], name, value)
        else
          super(name, value)
        end
      end

      def read_attribute(name, options = {})
        options = {:translated => true, :locale => nil}.merge(deprecated_options(options))
        if (self.class.translated?(name) && options[:translated]) && (value = globalize.fetch(options[:locale] || SingleTableGlobalize3.locale, name))
          value
        else
          super(name)
        end
      end

      def attribute_names
        translated_attribute_names.map(&:to_s) + super
      end

      def translated?(name)
        self.class.translated?(name)
      end

      def translated_attributes
        translated_attribute_names.inject({}) do |attributes, name|
          attributes.merge(name.to_s => translation[name.to_s].try(:value))
        end
      end

      # This method is basically the method built into Rails
      # but we have to pass {:translated => false}
      def untranslated_attributes
        attrs = {}
        attribute_names.each do |name|
          attrs[name] = read_attribute(name, {:translated => false})
        end
        attrs
      end

      def set_translations(options)
        options.keys.each do |locale|
          options[locale].each do |key, value|
            raise NoMethodError.new("unknown attribute: #{key}") unless attribute_names.flatten.include?(key.to_s)
            translation = translation_for(locale, key.to_s)
            translation.value = value
            translation.save
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

      def translation
        translations_for_locale(::SingleTableGlobalize3.locale)
      end

      def translation_for(locale, name, build_if_missing = true)
        translation_caches[locale] ||= {}
        translation_caches[locale][name] ||= (translations.detect{|t| t.locale == locale && t.attribute_name == name.to_s}) ||
          (translations.attribute(name).with_locale(locale).first) ||
          (translations.build(:locale => locale, :attribute_name => name) if build_if_missing)
      end

      def translations_for_locale(locale)
        translation_caches[locale] = if translations.loaded?
                                       translations.select{|t| t.locale.to_s == locale.to_s }
                                     else
                                       translations.with_locale(locale)
                                     end.inject({}) do |hash, t|
                                       hash.update(t.attribute_name => t)
                                     end
      end

      def translation_caches
        @translation_caches ||= {}
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
