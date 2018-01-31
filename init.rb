require 'sptime_hook'

Redmine::Plugin.register :redmine_spent_time do
  name 'Redmine Spent Time plugin'
  author 'DSQUADTECHNOLOGIES'
  description 'This is a plugin for Redmine'
  version '0.0.1'
  url 'http://www.redmine.org/plugins/remine-spent-time'
  author_url 'http://example.com/about'  
end

Redmine::MenuManager.map :application_menu do |menu|
	menu.push :sptime, { :controller => 'sptime', :action => 'index' }, :caption => :label_time
end

Redmine::MenuManager.map :project_menu do |menu|
	menu.push :sptime, {:controller => 'sptime', :action => 'index'}, :param => :project_id, :caption => :label_time,
              :parent => :new_object
end

Redmine::MenuManager.map :admin_menu do |menu|	
	menu.push :spcompany, { :controller => 'spcompany', :action => 'index' }, :caption => :label_company, :if => Proc.new { Object.new.extend(SptimeHelper).checkCpyPermission}, :html => {:class => 'icon icon-stats'}
end
