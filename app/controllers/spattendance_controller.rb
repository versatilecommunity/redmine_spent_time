class SpattendanceController < ApplicationController
  unloadable
  before_filter :require_login
  menu_item :spattendance
  include SptimeHelper


  def index
	@year ||= User.current.today.year
	@month ||= User.current.today.month
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
	
  end

end
