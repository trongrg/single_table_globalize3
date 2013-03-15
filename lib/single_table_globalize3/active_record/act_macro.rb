module SingleTableGlobalize3
  module ActiveRecord
    module ActMacro
      def translates(*attr_names)

        options = attr_names.extract_options!
        setup_translates!(options) unless translates?

        attr_names = attr_names.map(&:to_sym)
        attr_names -= translated_attribute_names if defined?(translated_attribute_names)

        attr_names.each do |attr_name|
          # Create accessors for the attribute.
          translated_attr_accessor(attr_name)
          translations_accessor(attr_name)

          # Add attribute to the list.
          self.translated_attribute_names << attr_name
        end
      end

      def translates?
        included_modules.include?(InstanceMethods)
      end

      protected
      def setup_translates!(options)
        setup_class_attributes(options)

        include InstanceMethods
        extend  ClassMethods

        has_many :translations, :class_name  => translation_class.name,
                                :foreign_key => :translatable_id,
                                :dependent   => :destroy,
                                :as => :translatable

        after_create :save_translations!
        after_update :save_translations!

        setup_locale_attribute

        setup_versioning if options[:versioning]
      end

      def setup_class_attributes(options)
        class_attribute :translated_attribute_names, :translation_options, :fallbacks_for_empty_translations
        self.translated_attribute_names       = []
        self.translation_options              = options
        self.fallbacks_for_empty_translations = options[:fallbacks_for_empty_translations]
      end

      def setup_versioning
        ::ActiveRecord::Base.extend(SingleTableGlobalize3::Versioning::PaperTrail)
        has_paper_trail :meta => {:locale => lambda{|record| record.locale}}
      end

      def setup_locale_attribute
        attr_accessor :locale unless self.attribute_names.include?('locale')

        # if attr_accessible is explicitly defined in the class, add locale to it
        attr_accessible :locale if self.accessible_attributes.to_a.present?
      end
    end
  end
end
