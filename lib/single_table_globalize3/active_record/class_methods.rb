module SingleTableGlobalize3
  module ActiveRecord
    module ClassMethods
      include WithTranslations

      if RUBY_VERSION < '1.9'
        def respond_to?(method_id, *args, &block)
          supported_on_missing?(method_id) || super
        end
      else
        def respond_to_missing?(method_id, include_private = false)
          supported_on_missing?(method_id) || super
        end
      end

      unless respond_to?(:attribute_names)
        def attribute_names
          @attribute_names ||= if !abstract_class? && table_exists?
                                 column_names
                               else
                                 []
                               end
        end
      end

      def supported_on_missing?(method_id)
        return super unless RUBY_VERSION < '1.9' || respond_to?(:translated_attribute_names)
        match = defined?(::ActiveRecord::DynamicFinderMatch) && (::ActiveRecord::DynamicFinderMatch.match(method_id) || ::ActiveRecord::DynamicScopeMatch.match(method_id))
        return false if match.nil?

        attribute_names = match.attribute_names.map(&:to_sym)
        translated_attributes = attribute_names & translated_attribute_names
        return false if translated_attributes.empty?

        untranslated_attributes = attribute_names - translated_attributes
        return false if untranslated_attributes.any?{|unt| ! respond_to?(:"scoped_by_#{unt}")}
        return [match, attribute_names, translated_attributes, untranslated_attributes]
      end

      def method_missing(method_id, *arguments, &block)
        match, attribute_names, translated_attributes, untranslated_attributes = supported_on_missing?(method_id)
        return super unless match

        scope = scoped

        translated_attributes.each do |attr|
          scope = scope.with_translated_attribute(attr, arguments[attribute_names.index(attr)])
        end

        untranslated_attributes.each do |unt|
          index = attribute_names.index(unt)
          raise StandarError unless index
          scope = scope.send(:"scoped_by_#{unt}", arguments[index])
        end

        if defined?(::ActiveRecord::DynamicFinderMatch) && match.is_a?(::ActiveRecord::DynamicFinderMatch)
          if match.instantiator? and scope.blank?
            return scope.find_or_instantiator_by_attributes match, attribute_names, *arguments, &block
          end
          match_finder_method = match.finder.to_s
          match_finder_method << "!" if match.bang? && ::ActiveRecord::VERSION::STRING >= "3.1.0"
          return scope.send(match_finder_method).tap do |found|
            found.is_a?(Array) ? found.map { |f| f.translations.reload } : found.translations.reload unless found.nil?
          end
        end
        return scope
      end

      def find_or_instantiator_by_attributes(match, attributes, *args)
        options = args.size > 1 && args.last(2).all?{ |a| a.is_a?(Hash) } ? args.extract_options! : {}
        protected_attributes_for_create, unprotected_attributes_for_create = {}, {}
        args.each_with_index do |arg, i|
          if arg.is_a?(Hash)
            protected_attributes_for_create = args[i].with_indifferent_access
          else
            unprotected_attributes_for_create[attributes[i]] = args[i]
          end
        end

        record = if ::ActiveRecord::VERSION::STRING < "3.1.0"
          new do |r|
            r.send(:attributes=, protected_attributes_for_create, true) unless protected_attributes_for_create.empty?
            r.send(:attributes=, unprotected_attributes_for_create, false) unless unprotected_attributes_for_create.empty?
          end
        else
          new(protected_attributes_for_create, options) do |r|
            r.assign_attributes(unprotected_attributes_for_create, :without_protection => true)
          end
        end
        yield(record) if block_given?
        record.send(match.bang? ? :save! : :save) if match.instantiator.eql?(:create)

        record
      end

    protected

      def translated_attr_accessor(name)
        define_method(:"#{name}=") do |value|
          write_attribute(name, value)
        end
        define_method(name) do |*args|
          read_attribute(name, {:locale => args.first})
        end
        alias_method :"#{name}_before_type_cast", name
      end

      def translations_accessor(name)
        define_method(:"#{name}_translations") do
          translations.attribute_translations(name).merge(globalize.fetch_locales(name))
        end
        define_method(:"#{name}_translations=") do |value|
          value.each do |(locale, value)|
            write_attribute name, value, :locale => locale
          end
        end
      end
    end
  end
end
