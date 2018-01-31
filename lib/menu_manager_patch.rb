require_dependency '../lib/redmine/menu_manager'

# redmine only differs between project_menu and application_menu! but we want to display the
# time_tracker submenu only if the plugin specific controllers are called
module Redmine::MenuManager::MenuHelper
  def display_main_menu?(project)
    Redmine::MenuManager.items(menu_name(project)).children.present?
  end

  def render_main_menu(project)
    #render_menu(menu_name(project), project)
	if menu_name = controller.current_menu(project)
       render_menu(menu_name(project), project) 
    end
  end

  private

  def menu_name(project)
    if project && !project.new_record?
      :project_menu
    else
	  controllerArr = ["sptime", "spcompany"]
	  externalMenus = call_hook :external_sptime_menus
	   externalMenus = externalMenus.split(' ')
	  unless externalMenus.blank?
		controllerArr = controllerArr + externalMenus
	  end
      if controllerArr.include? params[:controller]
        :sptime_menu
      else
        :application_menu
      end
    end
  end
end