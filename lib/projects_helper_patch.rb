require_dependency 'projects_helper'

module ProjectsHelperPatch
  
  def self.included(klass) # :nodoc:
    klass.class_eval do
      settings_method = instance_method(:project_settings_tabs)
      
      define_method(:project_settings_tabs) do
        tabs = settings_method.bind(self).call()
        if User.current.allowed_to?(:manage_carousels, @project) && @project.module_enabled?('carousels')
          tabs << {:name => 'carousels', :action => :manage_carousels, :partial => 'carousels/index', :label => :label_carousels}
        end
        tabs
      end
      
    end
  end
  
end