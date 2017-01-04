require 'rails/generators'

class EntityGeneratorController < ApplicationController
  include EntityGeneratorHelper

  menu_item :entity_generator

  before_filter :authorize_global
  before_filter :find_plugin_name, :find_entities, only: [:create]

  def new
    @entities = [create_entity]
    @create_new_plugin = true
  end

  def create
    if @plugin_name.present? && @entities.present?
      associations = association_table(@entities)
      Rails::Generators.invoke('redmine_extensions:plugin', [@plugin_name]) if params[:plugin_create].to_boolean
      @entities.each_with_index do |entity, index|
        generator_arguments = prepare_generator_arguments_from_entity(entity, associations)

        Rails::Generators.invoke('redmine_extensions:entity', generator_arguments)
      end
      flash[:notice] = l(:notice_entity_created)
      redirect_to new_entity_generator_path
    else
      flash[:error] = l(:error_bad_entity_input)
      @entities = params[:entities].present? ? params[:entities].values : []
      @create_new_plugin = params[:plugin_create].to_boolean
      render :new
    end
  end

  def add_form_field
    respond_to do |format|
      format.js
    end
  end

  def remove_form_field
    respond_to do |format|
      format.js
    end
  end

  private

  def find_entities
    @entities = params[:entities].values.select do |entity|
      (entity[:entity_name].present? && entity[:fields] && entity[:fields].values.detect {|field| field[:name].present? && field[:name] != 'name' }) || (entity[:entity_name].present? && entity[:basic_fields].present? && entity[:basic_fields].include?('name'))
    end if params[:entities].present? && params[:entities].values.present?
  end

  def find_plugin_name
    @plugin_name = params[:plugin_create].to_boolean ? params[:plugin_name] : params[:plugin_selector]
    @plugin_name = sanitize_name(@plugin_name).camelize
  end

  def prepare_generator_arguments_from_entity(entity, associations, options = {})
    process_basic_fields_to_corresponding_entity_options(entity)
    entity_name = sanitize_name(entity[:entity_name]).camelize
    entity_fields = sanitize_entity_fields(entity[:fields].to_h.values)
    entity_associations = sanitize_entity_associations(entity[:associations].to_h.values)
    entity_options = sanitize_entity_options(entity[:entity_options])

    # add belongs to associations
    association = associations[entity_name]
    if association && association['has_many']
      association['has_many'].each do |assoc|
        entity_associations << "belongs_to:#{assoc.underscore}"
      end
    end
    entity_associations.uniq!
    entity_associations = ['--associations'].concat(entity_associations) if entity_associations.present?

    generator_arguments = [@plugin_name, entity_name, *entity_fields,
                           *entity_associations, *entity_options]
    generator_arguments << '--entity' if options[:create_plugin_with_entity]
    generator_arguments
  end

  def process_basic_fields_to_corresponding_entity_options(entity)
    entity[:entity_options] ||= []
    entity[:entity_options] += basic_fields_options_and_opposites.collect do |option, opposite_option|
      entity[:basic_fields].include?(option) ? option : opposite_option if entity[:basic_fields]
    end

    entity[:fields] ||= {}
    entity[:basic_fields] ||= []
    if entity[:basic_fields].include?('name')
      entity[:fields] = { generate_uuid => {name: 'name', type: 'string'}}.merge(entity[:fields])
    end
  end

  def association_table(entities)
    associations = {}
    entities.each do |e|
      return associations if e[:associations].blank?
      e[:associations].each do |_key, values|
        if values[:name].present?
          class_name = values[:name].singularize.camelize
          associations[class_name] ||= {}
          associations[class_name][values[:type]] ||= []
          associations[class_name][values[:type]] << e[:entity_name]
        end
      end
    end
    associations
  end

end
