Redmine::MenuManager.map :admin_menu do |menu|
  menu.push :redmine_entity_generator, :new_entity_generator_path, {
    caption: :'button_redmine_entity_generator',
    html: {class: 'icon icon-templates'},
    if: Proc.new { User.current.allowed_to_globally?(:entity_generator_create_entity) },
    last: true,
  }
end

Redmine::AccessControl.map do |map|
  map.permission :entity_generator_create_entity, {entity_generator: [:new, :create]}, global: true
end
