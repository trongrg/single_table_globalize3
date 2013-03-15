require 'paper_trail'

module SingleTableGlobalize3
  module Versioning
    module PaperTrail
      # At present this isn't used but we may use something similar in paper trail
      # shortly, so leaving it around to reference easily.
      #def versioned_columns
        #super + self.class.translated_attribute_names
      #end

      def previous_version
        preceding_version = source_version ? source_version.previous : send(self.class.versions_association_name).for_this_locale.last
        preceding_version.reify if preceding_version
      end

      def source_version
        version = send(self.class.version_association_name)
        return version if version.try(:locale) == SingleTableGlobalize3.locale.to_s
      end
    end
  end
end

ActiveRecord::Base.class_eval do
  class << self
    def has_paper_trail_with_globalize(*args)
      has_paper_trail_without_globalize(*args)
      include SingleTableGlobalize3::Versioning::PaperTrail
    end
    alias_method_chain :has_paper_trail, :globalize
  end
end

Version.class_eval do

  before_save do |version|
    version.locale ||= SingleTableGlobalize3.locale.to_s
  end

  attr_accessible :locale

  def self.locale_conditions_to_sql
    "locale = '#{SingleTableGlobalize3.locale.to_s}'"
  end

  scope :for_this_locale, lambda{ { :conditions => locale_conditions_to_sql } }

  def sibling_versions_with_locales
    sibling_versions_without_locales.for_this_locale
  end
  alias_method_chain :sibling_versions, :locales
end
