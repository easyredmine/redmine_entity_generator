module EntityGeneratorHelper

  def data_for_entity_options
    [
      {label: l(:field_has_mail_notifications), option: '--mail'},
      {label: l(:field_acts_as_activity_provider), option: '--acts-as-activity_provider', description: l(:field_acts_as_activity_provider_description)},
      {label: l(:field_acts_as_attacheble), option: '--acts-as-attachable', description: l(:field_acts_as_attacheble_description)},
      {label: l(:field_acts_as_customizable), option: '--acts-as-customizable', description: l(:field_acts_as_customizable_description)},
      {label: l(:field_acts_as_event), option: '--acts-as-event', description: l(:field_acts_as_event_description)},
      {label: l(:field_acts_as_searchable), option: '--acts-as-searchable', description: l(:field_acts_as_searchable_description)},
    ]
  end

  def data_for_basic_entity_fields
    data = [{label: l(:field_name), option: 'name'}]

    basic_fields_options_and_opposites.keys.each do |option|
      option_text = option.gsub('-', '')
      data << {label: l("field_#{option_text}"), option: option, description: l("field_#{option_text}_description")}
    end
    data
  end

  def available_plugins_for_select(selected_plugin = nil)
    plugin_options = Redmine::Plugin.all.collect {|plugin| [plugin_name(plugin.name), plugin.id.to_s] }.sort_by(&:first)

    options_for_select(plugin_options, selected_plugin.to_s.underscore)
  end

  def plugin_name(plugin_name)
    plugin_name = l(plugin_name) if plugin_name.is_a?(Symbol)
    plugin_name
  end

  def entity_field_type_options_for_select(selected_association = nil)
    options_for_select(get_allowed_field_types.collect {|type| [l("label_#{type}"), type] }, selected_association.to_s)
  end

  def entity_association_type_options_for_select(selected_field_type = nil)
    options_for_select(get_allowed_association_types.collect {|type| [l("label_#{type}"), type] }.sort_by(&:first), selected_field_type.to_s)
  end

  def sanitize_entity_options(entity_options = [])
    entity_options ||= []
    allowed_options = default_entity_options_and_opposites.keys
    entity_options.delete_if {|current_option| allowed_options.exclude?(current_option) }

    set_default_options_opposites_in_entity_options(entity_options) + ['--skip']
  end

  def set_default_options_opposites_in_entity_options(entity_options = [])
    default_entity_options_and_opposites.each do |default_option, opposite_option|
      entity_options << opposite_option if entity_options.exclude?(default_option)
    end
    entity_options
  end

  def sanitize_name(name)
    I18n.transliterate(name || '').tr(' ', '_')
  end

  def sanitize_entity_fields(fields = [])
    fields.collect do |field|
      if field[:type].in?(get_allowed_field_types) && field[:name].present?
        sanitized_field = "#{sanitize_name(field[:name])}:#{field[:type]}"
        sanitized_field << ':index' if field.key?(:index)
      end
      sanitized_field
    end.compact
  end

  def sanitize_entity_associations(associations = [])
    associations = associations.collect do |association|
      if association[:type].in?(get_allowed_association_types) && association[:name].present?
        sanitized_field = "#{association[:type]}:#{sanitize_name(association[:name].underscore.pluralize)}"
        sanitized_field << ":#{association[:entity].camelize}" if association[:entity].present?
      end
      sanitized_field
    end.compact
    associations
  end

  def get_allowed_field_types
    [
      'string', 'text', 'integer', 'float', 'decimal', 'boolean', 'date', 'datetime', 'time'
    ]
  end

  def get_allowed_association_types
    [
      'has_one', 'has_many', 'belongs_to'
    ]
  end

  def default_entity_options_and_opposites
    {
      '--mail' => '--no-mail',
      '--acts-as-activity_provider' => '--no-acts-as-activity-provider',
      '--acts-as-attachable' => '--no-acts-as-attachable',
      '--acts-as-customizable' => '--no-acts-as-customizable',
      '--acts-as-event' => '--no-acts-as-event',
      '--acts-as-searchable' => '--no-acts-as-searchable'
    }.merge(basic_fields_options_and_opposites)
  end

  def basic_fields_options_and_opposites
    {
      '--author' => '--no-author',
      '--project' => '--no-project',
    }
  end

  def create_entity
    {
      entity_options: {},
      basic_fields: ['name']
    }
  end

  def generate_uuid
    SecureRandom.uuid.dasherize
  end
end
