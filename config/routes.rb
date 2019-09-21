# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

	get 'sptime/index', :to => 'sptime#index'
	
	get 'sptime/new', :to => 'sptime#new'
	
	match 'sptime/edit', :to => 'sptime#edit', :via => [:get, :post]
	
	get 'sptime/getProjectUsers', :to => 'sptime#getProjectUsers'
	
	get 'sptime/getCpyBranches', :to => 'sptime#getCpyBranches'
	
	get 'sptime/ProjectProperties', :to => 'sptime#ProjectProperties'
	
	post 'sptime/update', :to => 'sptime#update'
	
	delete 'sptime/destroy', :to => 'sptime#destroy'
	
	post 'spcompany/index', :to => 'spcompany#index'
	
	get 'spcompany/index', :to => 'spcompany#index'
	
	get 'spcompany/edit', :to => 'spcompany#edit'
	
	post 'spcompany/update', :to => 'spcompany#update'
	
	delete 'spcompany/destroy', :to => 'spcompany#destroy'
	
	post 'spcompany/branchUpdate', :to => 'spcompany#branchUpdate'
	
	get 'spprojectplan/index', :to => 'spprojectplan#index'
	
	get 'spprojectplan/edit', :to => 'spprojectplan#edit'
	
	delete 'spprojectplan/destroy', :to => 'spprojectplan#destroy'
	
	post 'spprojectplan/update', :to => 'spprojectplan#update'
	
	get 'spprojectplan/getProjectVersion', :to => 'spprojectplan#getProjectVersion'
	
	get 'spprojectplan/new', :to => 'spprojectplan#new'
	
	get 'spattendance/index', :to => 'spattendance#index'
	
	get 'spattendance/clockedit', :to => 'spattendance#clockedit'
	
	post 'spattendance/update', :to => 'spattendance#update'
	