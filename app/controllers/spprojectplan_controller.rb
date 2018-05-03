class SpprojectplanController < ApplicationController
  unloadable
  before_filter :require_login
  menu_item :stproject

	def index
		set_filter_session
		projectId = session[controller_name][:project_id]
		versionId = session[controller_name][:version_id]
		sqlQuery = "select p.id as project_id, p.name as project_name, pv.fixed_version_id, pv.hours, pv.start_date, pv.due_date, v.updated_on, v.name as version_name from projects p left join versions v on (v.project_id = p.id) left join (SELECT project_id, fixed_version_id, min(start_date) as start_date, max(due_date) as due_date, sum(estimated_hours) as hours FROM issues group by project_id, fixed_version_id) pv on (pv.project_id = p.id and (pv.fixed_version_id = v.id or pv.fixed_version_id is null))"
		sqlWhere = ""
		if !projectId.blank? && !versionId.blank?
			sqlWhere = " where p.id = #{projectId.to_i} and  pv.fixed_version_id = #{versionId.to_i} "
		elsif !projectId.blank? && versionId.blank?
			sqlWhere = " where p.id = #{projectId.to_i}"
		elsif projectId.blank? && !versionId.blank?
			sqlWhere = " where pv.fixed_version_id = #{versionId.to_i}"
		
		end
		sqlQuery = sqlQuery + sqlWhere unless sqlWhere.blank?
		sqlQuery = sqlQuery + " order by v.updated_on desc"
		findBySql(sqlQuery)
	end
	
	def new
	end

	def edit
		@projObj = nil
		@versionObj = nil
		@trackers =  Tracker.order(:name)
		if !params[:project_id].blank?
			@projObj = Project.where(:id => params[:project_id].to_i)
		end
		
		if !params[:version_id].blank?
			@versionObj = Version.find(params[:version_id].to_i)
		end
		
		if !params[:project_id].blank? && !params[:version_id].blank?
			@projPlan = Issue.where(:fixed_version_id => params[:version_id].to_i, :project_id =>  params[:project_id].to_i)
		end
	end
	
	def destroy
	end
	
	def update
		savedRows = 0
		deletedRows = 0
		projectObj = nil
		versionObj = nil
		totalRow = params[:totalrow].to_i		
		@rootHash = Hash.new 
		while savedRows < totalRow
			i = savedRows + deletedRows + 1
			# if params["issue_id#{i}"].blank? 
				# deletedRows = deletedRows + 1
				# next 
			# end
			issueParent = params["issue_parent#{i}"]
			parentId = issueParent.blank? ? nil : @rootHash[issueParent]
			issueObj = saveIssues( params["issue_id#{i}"],  params["issue_trackers#{i}"], params[:project_id], params["issue_subject#{i}"], params["issue_start_date#{i}"], params["issue_end_date#{i}"], params["issue_assignee#{i}"], params["issue_hours#{i}"], parentId, params[:version_id])
			@rootHash["#{params["issue_root#{i}"]}"] = issueObj.id
			
			savedRows = savedRows + 1
		end
		redirect_to :controller => controller_name,:action => 'index' , :tab => controller_name
		flash[:notice] = l(:notice_successful_update)
	end
	
	def saveIssues(id, trackerId, projectId, subject, startDate, dueDate, assignedId, estimatedHours, parentId, versionId)
		issueObj = nil
		begin
			unless id.blank?
				issueObj = Issue.find(id.to_i)
			else
				issueObj = Issue.new
			end
			issueObj.tracker_id = trackerId
			issueObj.project_id = projectId
			issueObj.subject = subject
			issueObj.start_date = startDate.to_date
			issueObj.due_date = dueDate.to_date
			issueObj.author_id = User.current.id
			issueObj.assigned_to_id = assignedId
			issueObj.estimated_hours = estimatedHours
			issueObj.parent_id = parentId
			issueObj.status_id = 1
			issueObj.priority_id = 2
			issueObj.lock_version =  0
			issueObj.done_ratio = 0
			issueObj.is_private = 0
			issueObj.fixed_version_id = versionId.to_i
			if issueObj.valid?
				issueObj.save
			else
				errormsg = issueObj.errors.full_messages.join("<br>")
			end
		rescue => ex
			logger.error ex.message
		end
		issueObj
	end
	
	def getProjectVersion		
		versionObj = Version.where(:project_id => params[:project_id].to_i)
		versionStr = ""
		if !versionObj.nil?
			versionObj.each do |m|
				versionStr << m.id.to_s() + ',' + m.name + "\n"
			end
		end
		respond_to do |format|
			format.text  { render :text => versionStr }
		end
	end
	
	def set_filter_session
		if params[:searchlist].blank? && session[controller_name].nil?
			session[controller_name] = {:company_id => params[:company_id], :branch_id => params[:branch_id], :project_id => params[:project_id], :user_id => params[:user_id], :from => params[:from], :to => params[:to], :frequency => params[:frequency], :version_id => params[:version_id]}
		elsif params[:searchlist] == controller_name
			session[controller_name][:company_id] = params[:company_id]
			session[controller_name][:branch_id] = params[:branch_id]
			session[controller_name][:project_id] = params[:project_id]
			session[controller_name][:user_id] = params[:user_id]
			session[controller_name][:from] = params[:from]
			session[controller_name][:to] = params[:to]
			session[controller_name][:frequency] = params[:frequency]
			session[controller_name][:version_id] = params[:version_id]
		end

	end
	
	def getAdditionalDropdown
		"spprojectplan/project_additionaldd"
	end
	
	def projectOnChangeMethod
		"projectVersionChanged('project_id', 'version_id', true);"
	end
	
	def findBySql(query)
		result = Issue.find_by_sql("select count(*) as id from (" + query + ") as v2")
	    @entry_count = result.blank? ? 0 : result[0].id
	    setLimitAndOffset()		
	    rangeStr = formPaginationCondition()	
	    @projectPlan = Issue.find_by_sql(query + rangeStr)
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
	
	def formPaginationCondition
		rangeStr = ""
		if ActiveRecord::Base.connection.adapter_name == 'SQLServer'				
			rangeStr = " OFFSET " + @offset.to_s + " ROWS FETCH NEXT " + @limit.to_s + " ROWS ONLY "
		else		
			rangeStr = " LIMIT " + @limit.to_s +	" OFFSET " + @offset.to_s
		end
		rangeStr
	end


end
