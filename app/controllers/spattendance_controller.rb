class SpattendanceController < ApplicationController
  unloadable
  before_filter :require_login
  menu_item :spattendance
  include SptimeHelper


  def index
	@year ||= User.current.today.year
	@month ||= User.current.today.month
	set_filter_session
	if params[:year] and params[:year].to_i > 1900
		@year = params[:year].to_i
		if params[:month] and params[:month].to_i > 0 and params[:month].to_i < 13
			@month = params[:month].to_i
		end
	end
		
		
	@calendar = Redmine::Helpers::Calendar.new(Date.civil(@year, @month, 1), current_language, :month)
	startDt = @calendar.startdt
	endDt = @calendar.enddt
	# get start date of the  first full week of the given month
	if @month != @calendar.startdt.month
		startDt = @calendar.startdt + 7.days
	end
	day = @calendar.startdt
	@attendancce = SpAttendance.where(user_id: 5)
	Rails.logger.info("=========== params #{params} ==================")
	Rails.logger.info("=========== @attendancce #{@attendancce.inspect} ==================")
	Rails.logger.info("=========== startDt : #{startDt} endDt #{endDt} ========")
	clockindex(startDt, endDt)
  end
  
	def clockindex(startDt, endDt)
	Rails.logger.info("============ lkindex init ==========")
		@clk_entries = nil
		@groups = Group.sorted.all
		set_filter_session
		retrieve_date_range
		@members = Array.new
		userIds = Array.new
		#userList = getGroupMembers
		#userList.each do |users|
		#	@members << [users.name,users.id.to_s()]
		#	userIds << users.id
		#end
		ids = User.current.id
		cpyId = session[controller_name][:company_id]
		branchId = session[controller_name][:branch_id]
		projectId = session[controller_name][:project_id]
		user_id = session[controller_name][:user_id]
		#group_id = session[controller_name][:group_id]
		#status = session[controller_name][:status]
		
		if user_id.blank? 
		   ids = User.current.id
		elsif user_id.to_i != 0 
		   ids = user_id.to_i
		#elsif projectId.to_i != 0
		#   ids =user_id.to_i == 0 ? (userIds.blank? ? 0 : userIds.join(',')) : user_id.to_i
		#else
		#   ids = userIds.join(',')
		end
		Rails.logger.info("============ before query  init ==========")
		@from = startDt
		@to = endDt
		noOfDays = 't4.i*1*10000 + t3.i*1*1000 + t2.i*1*100 + t1.i*1*10 + t0.i*1'
		sqlQuery = "select vw.id as user_id, vw.firstname, vw.lastname, vw.created_on, vw.selected_date as entry_date, evw.start_time, evw.end_time, evw.hours from
			(select u.id, u.firstname, u.lastname, u.created_on, v.selected_date from" + 
			"(select " + getAddDateStr(@from, noOfDays, false) + " selected_date from " +
			"(select 0 i union select 1 union select 2 union select 3 union select 4 union select 5 union select 6 union select 7 union select 8 union select 9) t0,
			 (select 0 i union select 1 union select 2 union select 3 union select 4 union select 5 union select 6 union select 7 union select 8 union select 9) t1,
			 (select 0 i union select 1 union select 2 union select 3 union select 4 union select 5 union select 6 union select 7 union select 8 union select 9) t2,
			 (select 0 i union select 1 union select 2 union select 3 union select 4 union select 5 union select 6 union select 7 union select 8 union select 9) t3,
			 (select 0 i union select 1 union select 2 union select 3 union select 4 union select 5 union select 6 union select 7 union select 8 union select 9)t4)v,
			 (select u.id, u.firstname, u.lastname, u.created_on from users u where u.type = 'User' ) u
			 WHERE  v.selected_date between '#{@from}' and '#{@to}' order by u.id, v.selected_date) vw left join
			 (select min(start_time) as start_time, max(end_time) as end_time, " + getConvertDateStr('start_time') + "
			 entry_date,sum(hours) as hours, user_id from sp_attendances WHERE " + getConvertDateStr('start_time') +" between '#{@from}' and '#{@to}'			
			 group by user_id, " + getConvertDateStr('start_time') + ") evw on (vw.selected_date = evw.entry_date and vw.id = evw.user_id) where vw.id in(#{ids}) "
			 Rails.logger.info("============ fomed qyery  init #{sqlQuery} ==========")
			findBySql(sqlQuery, SpAttendance)
			Rails.logger.info("============ After excute #{@clk_entries.inspect} ==========")
	end
	
	
	def clockedit
		sqlQuery = "select a.id,a.user_id, a.start_time, a.end_time, a.hours, u.firstname, u.lastname FROM users u
			left join sp_attendances a  on u.id = a.user_id and #{getConvertDateStr('a.start_time')} = '#{params[:date]}' where u.id = '#{params[:user_id]}' ORDER BY a.start_time"
		@wkattnEntries = SpAttendance.find_by_sql(sqlQuery)
	end	
	
	def getMembersbyGroup
		group_by_users=""
		userList=[]
		userList = getGroupMembers
		userList.each do |users|
			group_by_users << users.id.to_s() + ',' + users.name + "\n"
		end
		respond_to do |format|
			format.text  { render :text => group_by_users }
		end
	end	
	
	def getGroupMembers
		userList = nil
		group_id = nil
		if (!params[:group_id].blank?)
			group_id = params[:group_id]
		else
			group_id = session[controller_name][:group_id]
		end
		
		if !group_id.blank? && group_id.to_i > 0
			userList = User.in_group(group_id) 
		else
			userList = User.order("#{User.table_name}.firstname ASC,#{User.table_name}.lastname ASC")
		end
		userList
	end
	# Retrieves the date range based on predefined ranges or specific from/to param dates
	  def retrieve_date_range
		@free_period = false
		@from, @to = nil, nil
		period_type = session[controller_name][:period_type]
		period = session[controller_name][:period]
		fromdate = session[controller_name][:from]
		todate = session[controller_name][:to]
		if (period_type == '1' || (period_type.nil? && !period.nil?)) 
		  case period.to_s
		  when 'today'
			@from = @to = Date.today
		  when 'yesterday'
			@from = @to = Date.today - 1
		  when 'current_week'
			@from = getStartDay(Date.today - (Date.today.cwday - 1)%7)
			@to = Date.today #@from + 6
		  when 'last_week'
			@from =getStartDay(Date.today - 7 - (Date.today.cwday - 1)%7)
			@to = @from + 6
		  when '7_days'
			@from = Date.today - 7
			@to = Date.today
		  when 'current_month'
			@from = Date.civil(Date.today.year, Date.today.month, 1)
			@to = Date.today #(@from >> 1) - 1
		  when 'last_month'
			@from = Date.civil(Date.today.year, Date.today.month, 1) << 1
			@to = (@from >> 1) - 1
		  when '30_days'
			@from = Date.today - 30
			@to = Date.today
		  when 'current_year'
			@from = Date.civil(Date.today.year, 1, 1)
			@to = Date.today 
		  end
		
		elsif period_type == '2' || (period_type.nil? && (!fromdate.nil? || !todate.nil?))
		  begin; @from = fromdate.to_s.to_date unless fromdate.blank?; rescue; end
		  begin; @to = todate.to_s.to_date unless todate.blank?; rescue; end
		  @free_period = true
		else				
			@from = Date.civil(Date.today.year, Date.today.month, 1)
			@to = Date.today #(@from >> 1) - 1
		end    

		@from, @to = @to, @from if @from && @to && @from > @to

	end
	
    def projectOnChangeMethod
		"changedMembers();"
	end
	
	def getAdditionalDropdown		
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
	
	def findBySql(query, model)
		result = model.find_by_sql("select count(*) as id from (" + query + ") as v2")
		@entry_count = result.blank? ? 0 : result[0].id
        setLimitAndOffset()		
		rangeStr = formPaginationCondition()		
		@clk_entries = model.find_by_sql(query + " order by vw.selected_date desc, vw.firstname " + rangeStr )
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
