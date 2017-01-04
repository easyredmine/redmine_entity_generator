post 'entity_generator', to: 'entity_generator#create', as: 'entity_generator'
get 'entity_generator/new', to: 'entity_generator#new', as: 'new_entity_generator'
get 'entity_generator/add_form_field', to: 'entity_generator#add_form_field', as: 'add_form_field_entity_generator'
get 'entity_generator/remove_form_field', to: 'entity_generator#remove_form_field', as: 'remove_form_field_entity_generator'