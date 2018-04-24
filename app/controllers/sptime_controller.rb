class SptimeController < ApplicationController
	unloadable
	include SptimeHelper
	before_filter :require_login
	menu_item :sptime


	def index	
		projectIds = ""
		set_filter_session
		cpyId = session[controller_name][:company_id]
		branchId = session[controller_name][:branch_id]
		projectId = session[controller_name][:project_id]
		userId = session[controller_name][:user_id]
		from = session[controller_name][:from]
		to = session[controller_name][:to]
		frequency = session[controller_name][:frequency]
		if !userId.blank?
			entries = TimeEntry.where(:user_id => userId, :spent_on => from.. to)
		elsif !projectId.blank?
			projectIds = projectId
		elsif !branchId.blank?
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
		startDate = getStartDate((from.blank? ? Date.today : from.to_date) , frequency)
		endDate = getEndDate((to.blank?  ? Date.today : to.to_date), frequency)
		query = weeklyQuery(projectIds, userId, startDate, endDate, frequency)
		findBySql(query, TimeEntry)
	end

	def findBySql(query, model)
		result = model.find_by_sql("select count(*) as id from (" + query + ") as v2")
		@entry_count = result.blank? ? 0 : result[0].id
		setLimitAndOffset()		
		rangeStr = formPaginationCondition()	
		@timeEntries = model.find_by_sql(query + rangeStr )	
	end

	def formPaginationCondition
		rangeStr = ""
		if ActiveRecord::Base.connection.adapter_name == 'SQLServer'				
			rangeStr = " OFFSET " + @offset.to_s + " ROWS FETCH NEXT " + @limit.to_s + " ROWS ONLY "
		else		
			rangeStr = " LIMIT " + @limit.to_s +	" OFFSET " + @offset.to_s
		end
		rangeStr
	end
	
	def new
		@timeEntries = nil
		set_filter_session
		frequency = params[:frequency].blank? ? session[controller_name][:frequency] : params[:frequency]
		unless params[:spent_on].blank?
			spentOn = DateTime.parse(params[:spent_on])
			startDate = getStartDate(spentOn.to_date, frequency)
			endDate = getEndDate(spentOn.to_date, frequency)
			@timeEntries = TimeEntry.find_by_sql(editTimeEntryQuery(startDate, endDate, params[:user_id]))
		end
	end

	def editTimeEntryQuery(from, to, userIds)
		formula = 't4.i*1*10000 + t3.i*1*1000 + t2.i*1*100 + t1.i*1*10 + t0.i*1'
		sqlQuery = "select vw.id as user_id, vw.firstname, vw.lastname, vw.created_on, vw.selected_date as entry_date, evw.spent_on, evw.hours, evw.project_id, evw.issue_id, evw.comments, evw.activity_id, evw.time_entry_id from (select u.id, u.firstname, u.lastname, u.created_on, v.selected_date from(select "+  getAddDateStr(from, formula, true)  +" selected_date from (select 0 i union select 1 union select 2 union select 3 union select 4 union select 5 union select 6 union select 7 union select 8 union select 9) t0, (select 0 i union select 1 union select 2 union select 3 union select 4 union select 5 union select 6 union select 7 union select 8 union select 9) t1, (select 0 i union select 1 union select 2 union select 3 union select 4 union select 5 union select 6 union select 7 union select 8 union select 9) t2, (select 0 i union select 1 union select 2 union select 3 union select 4 union select 5 union select 6 union select 7 union select 8 union select 9) t3,(select 0 i union select 1 union select 2 union select 3 union select 4 union select 5 union select 6 union select 7 union select 8 union select 9)t4)v, (select u.id, u.firstname, u.lastname, u.created_on from users u where u.type = 'User' ) u WHERE  v.selected_date between '#{from}' and '#{to}' order by u.id, v.selected_date) vw left join (select spent_on, hours, user_id, project_id, issue_id, comments, activity_id, id as time_entry_id from time_entries WHERE spent_on between '#{from}' and '#{to}') evw on (vw.selected_date = evw.spent_on and vw.id = evw.user_id) "

		sqlQuery = sqlQuery + " where vw.id in(#{userIds})" unless userIds.blank?
		sqlQuery = sqlQuery + "   order by vw.selected_date desc, vw.firstname"

		sqlQuery
	end

	def weeklyQuery(projectIds, userId, from, to, aggregateBy)
		interval = getIntervalAndType(aggregateBy)
		sqlQuery = "select t.user_id, sum(t.hours)as total_hours, p.start_date, p.end_date from (select "+getAddDateIntervalStr(from, interval[1], interval[0], false)+" start_date, " +
		+ getAddDateStr(getAddDateIntervalStr(from, interval[1], interval[0], true), -1, false)+ " end_date from 
		(select 0 i union select 1 union select 2 union select 3 union select 4 union select 5 union select 6 union select 7 union select 8 union select 9) t0,(select 0 i union select 1 union select 2 union select 3 union select 4 union select 5 union select 6 union select 7 union select 8 union select 9) t1, (select 0 i union select 1 union select 2 union select 3 union select 4 union select 5 union select 6 union select 7 union select 8 union select 9) t2, (select 0 i union select 1 union select 2 union select 3 union select 4 union select 5 union select 6 union select 7 union select 8 union select 9) t3, (select 0 i union select 1 union select 2 union select 3 union select 4 union select 5 union select 6 union select 7 union select 8 union select 9)t4 
		where "
		if interval[0] == 'M'
			sqlQuery = sqlQuery + " #{getIntervalFormula(interval[1])} < (9999*12 - (MONTH('#{from}') + (YEAR('#{from}')*12))) AND "
		end
		sqlQuery = sqlQuery + getAddDateIntervalStr(from, interval[1], interval[0], false) + " between '#{from}' and '#{to}' ) p left join time_entries t on (t.spent_on between p.start_date and p.end_date" 
		unless userId.blank?
			sqlQuery = sqlQuery + " and t.user_id in (#{userId})"
		end
		unless projectIds.blank?
			sqlQuery = sqlQuery + " and t.project_id in (#{projectIds})"	
		end
		sqlQuery = sqlQuery + " )" 
		sqlQuery = sqlQuery +	" group by t.user_id, p.start_date, p.end_date"
		sqlQuery = "select temp.user_id, u.firstname, u.lastname, temp.total_hours, temp.start_date, temp.end_date from ( "+sqlQuery+") temp left join users u on u.id = temp.user_id"
	end

	def getStartDate(spentOn, type)
		startDate = Date.today
		case type
		when 'W'
			startDate = spentOn.beginning_of_week
		when 'M'
			startDate = spentOn.beginning_of_month
		when 'Q'
			startDate = spentOn.beginning_of_quarter
		when 'Y'
			startDate = spentOn.beginning_of_year
		else
			startDate = spentOn
		end
		startDate.strftime("%F")
	end

	def getEndDate(spentOn, type)
		endDate = Date.today.end_of_week
		case type
		when 'W'
			endDate = spentOn.end_of_week
		when 'M'
			endDate = spentOn.end_of_month
		when 'Q'
			endDate = spentOn.end_of_quarter
		when 'Y'
			endDate = spentOn.end_of_year
		else
			endDate = spentOn
		end
		endDate.strftime("%F")
	end

	def edit
	end

	def update
		errorMsg = ""
		entrylength = params[:totalrow].to_i
		arrId = TimeEntry.pluck(:id)
		isSaved = false
		frequencyVal = params[:frequency]
		spentDate = Date.today
		userId = User.current.id
		for i in 1..entrylength
			if params["time_entry_id#{i}"].blank? 
				timeEntries = TimeEntry.new
			else 
				timeEntries = TimeEntry.find(params["time_entry_id#{i}"].to_i)
			end
			timeEntries.project_id = params["project_id#{i}"]
			timeEntries.user_id = params["member_id#{i}"]#.strftime('%F')
			userId = params["member_id#{i}"].to_i
			timeEntries.issue_id = params["issue_id#{i}"]
			timeEntries.hours = params["hours#{i}"]
			timeEntries.activity_id = params["activity_id#{i}"]
			timeEntries.comments = params["comment#{i}"]
			timeEntries.spent_on = params["spent_on#{i}"]
			spentDate = params["spent_on#{i}"]
			if timeEntries.save()	
				arrId << timeEntries.id
				isSaved = true
			else
				errorMsg =  timeEntries.errors.full_messages.join("<br>")
			end
		end
		TimeEntry.where.not(:id => arrId).delete_all()
		if !errorMsg.blank? && !isSaved
			flash[:error] = errorMsg
			redirect_to :controller => 'sptime', :action => 'new', :frequency => frequencyVal.to_s, :spent_on => spentDate, :user_id => userId
		else			
			redirect_to :action => 'index' 
			flash[:notice] = l(:notice_successful_update)
		end
	end

	def set_filter_session
		if params[:searchlist].blank? && session[controller_name].nil?
			session[controller_name] = {:company_id => params[:company_id], :branch_id => params[:branch_id], :project_id => params[:project_id], :user_id => params[:user_id], :from => params[:from], :to => params[:to], :frequency => params[:frequency]}
		elsif params[:searchlist] == controller_name
			session[controller_name][:company_id] = params[:company_id]
			session[controller_name][:branch_id] = params[:branch_id]
			session[controller_name][:project_id] = params[:project_id]
			session[controller_name][:user_id] = params[:user_id]
			session[controller_name][:from] = params[:from]
			session[controller_name][:to] = params[:to]
			session[controller_name][:frequency] = params[:frequency]
		end

	end

	def setLimitAndOffset		
		if api_request?
			@offset, @limit = api_offset_and_limit
			if !params[:limit].blank?
				@limit = params[:limit]
			end
			if !params[:offset].blank?
				@offset = params[:offset]
			end
		else
			@entry_pages = Paginator.new @entry_count, per_page_option, params['page']
			@limit = @entry_pages.per_page
			@offset = @entry_pages.offset
		end	
	end

	def getProjectUsers
		project = Project.find(params[:project_id])
		userStr = ""
		projmembers = project.members.order("#{User.table_name}.firstname ASC,#{User.table_name}.lastname ASC")

		if !projmembers.nil?
			projmembers = projmembers.to_a.uniq 
			projmembers.each do |m|
				userStr << m.user_id.to_s() + ',' + m.name + "\n"
			end
		end
		respond_to do |format|
			format.text  { render :text => userStr }
		end
	end

	def getCpyBranches
		user = User.current
		responseArr = "" 
		case params[:filter_type] 
		when 'branch'
			cpyObj = cpyBranches(params[:id])
			cpyObj.each do | entry |
				responseArr << entry.id.to_s() + ',' +  entry.name.to_s()  + "\n" 
			end
		when 'project'
			branchObj = getbranch(params[:id], params[:company_id])
			projObj = branchProjects(branchObj)
			projObj.each do | entry |
				responseArr << entry.id.to_s() + ',' +  entry.name.to_s()  + "\n" 
			end
		when 'member'
			getMembers(params[:project_id], params[:branch_id], params[:company_id])
			count = 0
			userArr = Array.new
			@memberObj.each do | entry |
				if count == 0 || !(userArr.include? (entry.user_id))
					userArr << entry.user_id
					responseArr << entry.user_id.to_s() + ',' +  entry.name.to_s()  + "\n" 
					count = count + 1
				end
			end
		end

		respond_to do |format|
			format.text  { render :text => responseArr }
		end		 
	end  

	def ProjectProperties
		responseArr = ""
		case params[:filter_type] 
		when 'Issue'
			project = Project.find(params[:id].to_i)
			issueObj = project.issues
			issueObj.each do | entry |
				responseArr << entry.id.to_s() + ',' +  entry.subject.to_s()  + "\n" 
			end
		when 'Member'
			project = Project.find(params[:id].to_i)
			userObj = project.users
			userObj = userObj.uniq
			userObj.each do | entry |
				responseArr << entry.id.to_s() + ',' +  (entry.firstname.to_s() + " " + entry.lastname.to_s())  + "\n" 
			end
		when 'Activity'
			project = Project.find(params[:id].to_i)
			userObj = project.activities
			userObj.each do | entry |
				responseArr << entry.id.to_s() + ',' +  entry.name.to_s()  + "\n" 
			end
		end

		respond_to do |format|
			format.text  { render :text => responseArr }
		end	
	end

	def destroy
	end
	
	def getAdditionalDropdown		
	end
	
	def projectOnChangeMethod
		"changedMembers();"
	end

end
