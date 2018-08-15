require 'sptime_hook'
require 'menu_manager_patch'

Redmine::Plugin.register :redmine_spent_time do
  name 'Redmine Spent Time plugin'
  author 'Versatile Community Inc'
  description 'This is a plugin for Redmine'
  version '0.2'
  url 'https://www.redmine.org/plugins/redmine_spent_time_versatile'
  author_url 'http://versatilecommunity.com/about'  
  
  menu :top_menu, :spTime, { :controller => 'sptime', :action => 'index' }, :caption => :label_time_sheet, :if => Proc.new { Object.new.extend(SptimeHelper).checkPermission}
  
  menu :admin_menu, :spcompany, { :controller => 'spcompany', :action => 'index' }, :caption => :label_company, :if => Proc.new { Object.new.extend(SptimeHelper).checkCpyPermission}, :html => {:class => 'icon icon-stats'}
end

Redmine::MenuManager.map :sptime_menu do |menu|
	menu.push :sptime, { :controller => 'sptime', :action => 'index' }, :caption => :label_time
	menu.push :stproject, { :controller => 'spprojectplan', :action => 'index' }, :caption => :label_proj_plan
end


