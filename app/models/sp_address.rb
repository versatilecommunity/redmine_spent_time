# SPENT TIME - Time sheet for service industry
# Copyright (C) 2017-2019  VERSATILE COMMUNITY INC
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

class SpAddress < ActiveRecord::Base
  unloadable
  validate :hasAnyValues
  
  def hasAnyValues
	errors.add(:base, (l(:label_address)  + " " + l('activerecord.errors.messages.blank'))) if address1.blank? && address2.blank? && work_phone.blank? && home_phone.blank? && mobile.blank? && email.blank? && fax.blank? && city.blank? && country.blank? && state.blank? && pin.blank? && id.blank?
  end
  
  def fullAddress
	fullAdd = (address1.blank? ? "" : address1 + "\n") + (address2.blank? ? "" : address2 + "\n")  + (city.blank? ? "" : city) + " " +  (state.blank? ? "" : state) + "\n" + (pin.blank? ? "" : pin.to_s )  + "\n" + (country.blank? ? "" : country)
	fullAdd
  end
end
