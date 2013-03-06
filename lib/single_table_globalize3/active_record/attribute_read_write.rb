module SingleTableGlobalize3
  module ActiveRecord
    module AttributeReadWrite
      delegate :translated_locales, :to => :translations
      def attributes
        super.merge(translated_attributes)
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


    end
  end
end
