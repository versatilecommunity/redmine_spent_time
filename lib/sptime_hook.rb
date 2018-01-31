class SptimeHook < Redmine::Hook::ViewListener

	def view_users_form(context={})
		branches = SpBranch.order('name')
		permissions = SpPermission.all
		brList = Array.new
		permissionsArr = Array.new
		unless permissions.blank?
			permissionsArr = permissions.pluck(:name, :id)
			permissionsArr.unshift(["",""])
		end
		unless branches.blank?
			brList = branches.collect {|t| ["#{t.name}", t.id] }			
			brList.unshift(["",""])
		end
		content = "<p>" + "#{context[:form].select :branch_id, brList, :label => :label_branches}" + "</p>".html_safe
		content << "<p>" + "#{context[:form].select :permission_id, permissionsArr, :label => :label_permissions}" + "</p>".html_safe
	end
end