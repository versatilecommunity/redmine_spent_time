# SPENT TIME - Time sheet for service industry
# Copyright (C) 2017-2018  DSQUADTECHNOLOGIES
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
module SptimeHelper

include ApplicationHelper

	User.class_eval do
	   belongs_to :userBranch, :class_name => 'SpBranch', :foreign_key => 'branch_id'
	   belongs_to :userPermission, :class_name => 'SpPermission', :foreign_key => 'permission_id'
	   safe_attributes 'branch_id', 'permission_id'
	end

	def checkPermission
		User.current.logged? 
	end
	
	def checkCpyPermission
		ret = false
		unless User.current.userPermission.blank?
			ret = User.current.userPermission.short_name == 'O' || User.current.userPermission.short_name == 'M'
		end
		ret
	end
	
	def companyArray(needBlank)
		cpyArr = SpCompany.order(:name).pluck(:name, :id)
		cpyArr.unshift(["",'']) if needBlank
		cpyArr
	end
	
	def branchArray(companyId, needBlank)	
		unless User.current.userPermission.blank?
			if (User.current.userPermission.short_name == 'M' || User.current.userPermission.short_name == 'O') && !User.current.admin
				brArr = SpBranch.where(:id => User.current.branch_id).pluck(:name, :id)
			end
		end
		if User.current.admin
			brArr = SpBranch.where(:company_id => companyId).order(:name).pluck(:name, :id)
		end
		brArr.unshift(["",'']) if needBlank && !brArr.blank?
		brArr
	end
	
	def projectsArray(branchId, companyId, needBlank)
	Rails.logger.info("========= branchId #{branchId} companyId #{companyId} ===================")
		projArr = Array.new
		branchObj = getbranch(branchId, companyId)
		if User.current.admin?
			projObj = branchProjects(branchObj)
		else
			projObj = User.current.projects
			Rails.logger.info("========== else projObj #{projObj.inspect} ==============")
		end
		Rails.logger.info("========== projObj #{projObj.inspect} ==============")
		projObj.each do | entry |
			projArr  << [entry.name.to_s(), entry.id ] 
		end		
		projArr.unshift(["",'']) if needBlank		
		projArr
	end
	
	def memberArray(projectId, branch_id, company_id, needBlank)
		memberArr = Array.new		
		if User.current.admin
			cpyId = company_id
		else
			cpyId = User.current.userBranch.company_id
		end
		getMembers(projectId, branch_id, cpyId)
		count = 0
		userArr = Array.new
		if !User.current.userPermission.blank?
			if User.current.userPermission.short_name == 'O' || User.current.userPermission.short_name == 'M' || User.current.userPermission.short_name == 'S'
				@memberObj.each do | entry |
					if count == 0 || !(userArr.include? (entry.user_id))
						userArr << entry.user_id
						memberArr << [entry.name.to_s(), entry.user_id]
						count = count + 1
					end
				end
			else
				memberArr << [User.current.name.to_s(), User.current.id]
			end
		end
		memberArr.unshift(["",'']) if needBlank
		memberArr
	end
	
	# Return Interval and type
	# interval[0] - Interval Type
	# interval[1] - Interval Value
	def getIntervalAndType(aggregateBy)
		interval = Array.new
		case aggregateBy
		when 'W'
			interval = ['D', 7]
		when 'Q'
			interval = ['M', 3]
		when 'Y'
			interval = ['M', 12]
		when 'M'
			interval = ['M', 1]
		else
			interval = ['D', 1]
		end
		interval
	end
	
	def getAddDateStr(dtfield, noOfDays, isStr)
		if isStr
			dtfield = "'#{dtfield}'"
		end
		if ActiveRecord::Base.connection.adapter_name == 'PostgreSQL'			 
			dateSqlStr = "date('#{dtfield}') + "	+ noOfDays.to_s
		elsif ActiveRecord::Base.connection.adapter_name == 'SQLite'			 
			dateSqlStr = "date('#{dtfield}' , '+' || " + "(#{noOfDays.to_s})" + " || ' days')"
		elsif ActiveRecord::Base.connection.adapter_name == 'SQLServer'		
			dateSqlStr = "DateAdd(d, " + noOfDays.to_s + ", #{dtfield})"
		else
			dateSqlStr = "adddate('#{dtfield}', " + noOfDays.to_s + ")"
		end		
		dateSqlStr
	end
	
	def getAddDateIntervalStr(dtfield,intervalVal,intervalType, isEnd)
		interval = getIntervalFormula(intervalVal)
		if isEnd
			interval = "(" + interval + "+ 1*#{intervalVal})" 
		end
		if intervalType == 'M'
			intervalSql = getAddMonthDateStr(dtfield,interval)
		else
			intervalSql = getAddDateStr(dtfield,interval, true)
		end
		intervalSql
	end
	
	def getAddMonthDateStr(dtfield,interval)
		#interval = getIntervalFormula(intervalVal)
		if ActiveRecord::Base.connection.adapter_name == 'PostgreSQL'			 
			dateSqlStr = "date('#{dtfield}') + interval '1 month' * "	+ interval.to_s
		elsif ActiveRecord::Base.connection.adapter_name == 'SQLite'			 
			dateSqlStr = "date('#{dtfield}' , '+' || " + "(#{interval.to_s})" + " || ' months')"
		elsif ActiveRecord::Base.connection.adapter_name == 'SQLServer'		
			dateSqlStr = "DateAdd(m, " + interval.to_s + ",'#{dtfield}')"
		else
			dateSqlStr = "adddate('#{dtfield}', INTERVAL " + interval.to_s + " MONTH )"
		end		
		dateSqlStr
	end
	
	def getIntervalFormula(intervalVal)
		"(t4.i*#{intervalVal}*10000 + t3.i*#{intervalVal}*1000 + t2.i*#{intervalVal}*100 + t1.i*#{intervalVal}*10 + t0.i*#{intervalVal})"
	end
	
	def getConvertDateStr(dtfield)		
		if ActiveRecord::Base.connection.adapter_name == 'SQLServer'		
			dateSqlStr = "cast(#{dtfield} as date)"
		else
			# For MySQL, PostgreSQL, SQLite
			dateSqlStr = "date(#{dtfield})"
		end
		dateSqlStr
	end
	
	def cpyBranches(companyId)
		unless companyId.blank?
			cpyObj = SpBranch.where(:company_id => companyId.to_i)
		else
			cpyObj = SpBranch.order(:name)
		end
		cpyObj		
	end

	def getbranch(branchId, companyId)
		projectArr = ""
		userIds = Array.new
		if !branchId.blank?
			branchObj = SpBranch.where(:id => branchId.to_i)
		elsif User.current.admin
			branchObj = SpBranch.where(:company_id => companyId.to_i).order(:name)
		else 
			branchObj = SpBranch.where(:id => User.current.branch_id)
		end
		branchObj		
	end

	def branchProjects(branchObj)
		userIds = Array.new
		branchObj.each do | entry |
			userIds << entry.users.pluck(:id)
		end		
		projObj = userProjects(userIds)				
		projObj		
	end

	def getMembers(projectId, branchId, companyId)
		@memberObj = []
		@tempMember = []
		if !params[:project_id].blank? && 
			@memberObj = Project.find(params[:project_id].to_i).members.order("#{User.table_name}.firstname ASC,#{User.table_name}.lastname ASC")	
		elsif User.current.admin?
			branchObj  = getbranch(branchId, companyId)
			projObj = branchProjects(branchObj)
			projObj.each do | entry |
				@memberObj += entry.members.order("#{User.table_name}.firstname ASC,#{User.table_name}.lastname ASC")
			end	
		else
			#projObj =  User.current.projects
			branchObj  = getbranch(branchId, companyId)
			projObj = branchProjects(branchObj)
			projObj.each do | entry |
				@memberObj += entry.members.order("#{User.table_name}.firstname ASC,#{User.table_name}.lastname ASC")
			end	
		end				
	end

	def userProjects(users)
		proj = nil
		projectIds = Member.where(:user_id => users).pluck(:project_id)
		proj = Project.where(:id => projectIds)
		proj
	end
	
	def aggergateHash
		hash_frequency = { '' => "", 'W' => l(:label_weekly), 'M'  => l(:label_monthly), 'Q' =>  l(:label_quarterly),  'Y' => l(:label_annually) }
		hash_frequency
	end
	
	def getProjectIds(cpyId, branchId, projectIds)
		if !branchId.blank?
			branchObj = getbranch(branchId, nil)
			projObj = branchProjects(branchObj)
			#projectIds = projObj.pluck(:id)
			projObj.each do |entry|
				projectIds = projectIds.blank? ? entry.id.to_s : projectIds + "," + entry.id.to_s
			end
		else
			cpyObj = cpyBranches(cpyId)
			branchIds = cpyObj.pluck(:id)

			branchIds.each do | br |
				branchObj = getbranch(br, nil)
				projObj = branchProjects(branchObj)
				projObj.each do |entry|
					projectIds = projectIds.blank? ? entry.id.to_s : projectIds + "," + entry.id.to_s
				end
			end
		end
		projectIds
	end
	
end
