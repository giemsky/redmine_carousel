class CarouselsController < ApplicationController
  unloadable
  
  menu_item :settings

  before_filter :find_project, :authorize
  before_filter :find_collections, :only => [:new, :create, :edit, :update]
  before_filter :find_carousel, :only => [:edit, :update, :destroy]

  def new
    @carousel = @project.carousels.build
  end
  
  def create
    @carousel = @project.carousels.create(params[:carousel])
    if @carousel.save
      flash[:notice] = l(:notice_successful_create)
      redirect_back
    else
      render :action => 'new'
    end
  end

  def edit; end
  
  def update
    @carousel.attributes = params[:carousel]
    
    if @carousel.save
      flash[:notice] = l(:notice_successful_update)
      redirect_back
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @carousel.destroy
    flash[:notice] = l(:notice_successful_delete)
    redirect_back
  end
  
  private
  
  def find_project
    # @project variable must be set before calling the authorize filter
    @project = Project.find(params[:project_id])
  end
  
  def find_carousel
    @carousel = @project.carousels.find(params[:id])
  end
  
  def find_collections
    @members = @project.members.all(:include => :user)
    @issue_priorities = IssuePriority.all
    @issue_categories = @project.issue_categories
    @trackers = @project.trackers
  end
  
  def redirect_back
    redirect_to :controller => 'projects', :action => 'settings', :tab => 'carousels', :id => @project
  end
end
