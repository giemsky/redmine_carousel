ActionController::Routing::Routes.draw do |map|
	map.resources :carousels, :except => [:index, :show], :path_prefix => 'projects/:project_id', :name_prefix => 'project_'
end
