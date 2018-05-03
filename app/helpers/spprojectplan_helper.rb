module SpprojectplanHelper
include SptimeHelper

	# Indentation of Subprojects based on levels
	def options_for_project(projects, needBlankRow=false)
		projArr = Array.new
		if needBlankRow
			projArr << [ "", ""]
		end
		
		#Project.project_tree(projects) do |proj_name, level|
		if !projects.blank?
			project_tree(projects) do |proj, level|
				indent_level = (level > 0 ? ('&nbsp;' * 2 * level + '&#187; ').html_safe : '')
				sel_project = projects.select{ |p| p.id == proj.id }
				projArr << [ (indent_level + sel_project[0].name), sel_project[0].id ]
			end
		end
		projArr
	end
	
	def assigneeUsers
		@projObj.map(&:assignable_users).reduce(:&)		
	end
end
