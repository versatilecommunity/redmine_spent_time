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
	# get start date of the  first full week of the given month
	if @month != @calendar.startdt.month
		startDt = @calendar.startdt + 7.days
	end
	day = @calendar.startdt
	@attendancce = SpAttendance.where(user_id: 5)
	Rails.logger.info("=========== params #{params} ==================")
	Rails.logger.info("=========== @attendancce #{@attendancce.inspect} ==================")
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

end
