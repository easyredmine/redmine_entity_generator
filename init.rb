Redmine::Plugin.register :redmine_entity_generator do
  name 'Easy Entity Generator plugin'
  author 'Easy Software Ltd'
  description 'new plugins & entities generator'
  version '2016'
  url 'www.easyredmine.com'
  author_url 'www.easysoftware.cz'
end

if Redmine::Plugin.registered_plugins[:easy_extensions].nil?
  require_relative 'after_init'
end
