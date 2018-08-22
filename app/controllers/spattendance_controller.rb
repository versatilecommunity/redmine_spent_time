class SpattendanceController < ApplicationController
  unloadable
  before_filter :require_login
  menu_item :spattendance
  include SptimeHelper


  def index
  end

end
