class SpcompanyController < ApplicationController
  unloadable



	def index
		@cpyEntries = nil
		if params[:accountname].blank?
		   entries = SpCompany.order(:name)
		else
			entries = SpCompany.where("name like ?", "%#{params[:name]}%").order(:name)
		end
		formPagination(entries)
	end


	def edit
		@cpyEntries = nil
		@branchEntry = nil
		@addressObj = nil 
		unless params[:company_id].blank?
			@cpyEntries = SpCompany.find(params[:company_id].to_i)
			@addressObj = @cpyEntries.address
			entries = @cpyEntries.branches
			@entry_count = entries.count
			setLimitAndOffset()
			@branchEntry = entries.order(:name).limit(@limit).offset(@offset)
		end		
	end
	
	def update
		spCompany = nil
		errorMsg = ""
		companyId = ""
		unless params[:company_id].blank?
			spCompany = SpCompany.find(params[:company_id].to_i)
		else
			spCompany = SpCompany.new
		end
		spCompany.name = params[:name]
		spCompany.service_tax_number = params[:service_tax_number] 
		spCompany.pan_number = params[:pan_number]
		spCompany.tin_cin_number = params[:tin_cin_number]
		spCompany.tax_number = params[:tax_number]
		spCompany.established_year = params[:established_year]
		spCompany.website = params[:website]
		if spCompany.valid?
			spCompany.address_id = updateAddress
			spCompany.save
			companyId = spCompany.id
		else
			errorMsg = spCompany.errors.full_messages.join("<br>")
		end
		
		if errorMsg.blank?
			redirect_to :controller => controller_name,:action => 'index' 
		    flash[:notice] = l(:notice_successful_update)
		else
			flash[:error] = errorMsg
		    redirect_to :controller => controller_name,:action => 'edit', :company_id => companyId
		end
	end
	
	def branchUpdate
		errorMsg = ""
		unless params[:actual_ids].blank?
			arrId = params[:actual_ids].split(",").map { |s| s.to_i } 
		end
		for i in 0..params[:branch_id].length-1
			if params[:branch_id][i].blank?
				branchEntries = SpBranch.new
			else
				branchEntries = SpBranch.find(params[:branch_id][i].to_i)
				arrId.delete(params[:branch_id][i].to_i)
			end
			branchEntries.name = params[:branch_name][i]
			branchEntries.established_year = params[:established_year][i]
			branchEntries.company_id = params[:branch_cpy_id].to_i
			unless branchEntries.save()
				errorMsg =  branchEntries.errors.full_messages.join("<br>")
			end
		end
		SpBranch.where(:id => arrId).delete_all()
				
		redirect_to :controller => controller_name, :action => 'edit', :company_id => branchEntries.company_id  
		flash[:notice] = l(:notice_successful_update)
		flash[:error] = errorMsg unless errorMsg.blank?
	end
	
	def formPagination(entries)
		@entry_count = entries.count
        setLimitAndOffset()
		@cpyEntries = entries.order(:name).limit(@limit).offset(@offset)
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
  
	def destroy
	end
	
	def updateAddress
		spAddress = nil
		addressId = nil
	    if params[:address_id].blank? || params[:address_id].to_i == 0
		    spAddress = SpAddress.new 
	    else
		    spAddress = SpAddress.find(params[:address_id].to_i)
	    end
		# For Address table
		spAddress.address1 = params[:address1]
		spAddress.address2 = params[:address2]
		spAddress.work_phone = params[:work_phone]
		spAddress.city = params[:city]
		spAddress.state = params[:state]
		spAddress.pin = params[:pin]
		spAddress.country = params[:country]
		spAddress.fax = params[:fax]
		spAddress.mobile = params[:mobile]
		spAddress.email = params[:email]		
		if spAddress.valid?
			spAddress.save
			addressId = spAddress.id
		end		
		addressId
	end

end
