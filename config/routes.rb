ActionController::Routing::Routes.draw do |map|
  
  map.resources :projects do |p|
  	p.resources :carousels, :except => [:index, :show]
  end
  
end