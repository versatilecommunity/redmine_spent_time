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

class SpCompany < ActiveRecord::Base
  unloadable
  belongs_to :address, :class_name => 'SpAddress', :dependent => :destroy
  has_many :branches, :class_name => 'SpBranch', :foreign_key => 'company_id', :dependent => :destroy
  validates_presence_of :name 
end