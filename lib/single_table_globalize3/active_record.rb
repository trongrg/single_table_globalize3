module SingleTableGlobalize3
  module ActiveRecord
    autoload :ActMacro,           'single_table_globalize3/active_record/act_macro'
    autoload :Adapter,            'single_table_globalize3/active_record/adapter'
    autoload :AttributeReadWrite, 'single_table_globalize3/active_record/attribute_read_write'
    autoload :Attributes,         'single_table_globalize3/active_record/attributes'
    autoload :ClassMethods,       'single_table_globalize3/active_record/class_methods'
    autoload :WithTranslations,   'single_table_globalize3/active_record/with_translations'
    autoload :Exceptions,         'single_table_globalize3/active_record/exceptions'
    autoload :InstanceMethods,    'single_table_globalize3/active_record/instance_methods'
    autoload :Migration,          'single_table_globalize3/active_record/migration'
    autoload :Translation,        'single_table_globalize3/active_record/translation'
  end
end
