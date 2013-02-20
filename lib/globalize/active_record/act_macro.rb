module Globalize
  module ActiveRecord
    module ActMacro
      def translates(*attr_names)

        options = attr_names.extract_options!
        setup_translates!(options) unless translates?

        attr_names = attr_names.map(&:to_sym)
        attr_names -= translated_attribute_names if defined?(translated_attribute_names)

        if attr_names.present?
          translation_class.instance_eval %{
            attr_accessible :#{attr_names.join(', :')}
          }

          attr_names.each do |attr_name|
            # Detect and apply serialization.
            serializer = self.serialized_attributes[attr_name.to_s]
            if serializer.present?
              if defined?(::ActiveRecord::Coders::YAMLColumn) &&
                 serializer.is_a?(::ActiveRecord::Coders::YAMLColumn)

                serializer = serializer.object_class
              end

              translation_class.send :serialize, attr_name, serializer
            end

            # Create accessors for the attribute.
            translated_attr_accessor(attr_name)
            translations_accessor(attr_name)

            # Add attribute to the list.
            self.translated_attribute_names << attr_name
          end
        end
      end

      def translates?
        included_modules.include?(InstanceMethods)
      end

      protected
      def setup_translates!(options)
        class_attribute :translated_attribute_names, :translation_options, :fallbacks_for_empty_translations
        self.translated_attribute_names = []
        self.translation_options        = options
        self.fallbacks_for_empty_translations = options[:fallbacks_for_empty_translations]

        include InstanceMethods
        extend  ClassMethods

        has_many :translations, :class_name  => translation_class.name,
                                :foreign_key => :translatable_id,
                                :dependent   => :destroy,
                                :as => :translatable

        after_create :save_translations!
        after_update :save_translations!

        translation_class.instance_eval %{ attr_accessible :locale }
      end
    end
  end
end
