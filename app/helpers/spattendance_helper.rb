module SpattendanceHelper
include SptimeHelper
include CalendarsHelper

	def link_to_spcalendar_display_day(calendarObject, options={})
		content = "<div >
						<a  href='#' class='spButton'>10:00</a>
						<a  href='#' class='spButtonEnd'>18:00</a>
						<a  href='#' class='spButtonHrs'>10:00</a>
				   </div>"
		content.html_safe
	end
	
	# def getAddDateStr(dtfield,noOfDays)
		# if ActiveRecord::Base.connection.adapter_name == 'PostgreSQL'			 
			# dateSqlStr = "date('#{dtfield}') + "	+ noOfDays.to_s
		# elsif ActiveRecord::Base.connection.adapter_name == 'SQLite'			 
			# dateSqlStr = "date('#{dtfield}' , '+' || " + "(#{noOfDays.to_s})" + " || ' days')"
		# elsif ActiveRecord::Base.connection.adapter_name == 'SQLServer'		
			# dateSqlStr = "DateAdd(d, " + noOfDays.to_s + ",'#{dtfield}')"
		# else
			# dateSqlStr = "adddate('#{dtfield}', " + noOfDays.to_s + ")"
		# end		
		# dateSqlStr
	# end
	
	def getConvertDateStr(dtfield)		
		if ActiveRecord::Base.connection.adapter_name == 'SQLServer'		
			dateSqlStr = "cast(#{dtfield} as date)"
		else
			# For MySQL, PostgreSQL, SQLite
			dateSqlStr = "date(#{dtfield})"
		end
		dateSqlStr
	end
end
