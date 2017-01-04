Redmine::Plugin.register :redmine_entity_generator do
  name 'Entity Generator'
  author 'Easy Software LTD'
  description 'New plugins & entities generator'
  version '2016'
  url 'https://www.easyredmine.com'
  author_url 'https://www.easyredmine.com'
end

easy_extensions = Redmine::Plugin.registered_plugins[:easy_extensions]
if easy_extensions.nil? || Gem::Version.new(easy_extensions.version) < Gem::Version.new('2016.03.00')
  require_relative 'after_init'
end