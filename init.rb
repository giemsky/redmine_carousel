require 'redmine'
require 'dispatcher'

# Patches to the Redmine core.
require_dependency 'member_patch'
require_dependency 'project_patch'
require_dependency 'issue_patch'
require_dependency 'user_patch'
require_dependency 'projects_helper_patch'

# Core extensions
require_dependency 'core_ext/time'

# Extend core classes through dispatcher so they can work also in development mode
Dispatcher.to_prepare do
  Issue.send(:include, IssuePatch)
  Member.send(:include, MemberPatch)
  Project.send(:include, ProjectPatch)
  User.send(:include, UserPatch)
  ProjectsHelper.send(:include, ProjectsHelperPatch)
end

Redmine::Plugin.register :redmine_carousel do
  name 'Redmine Carousel plugin'
  author 'Grzegorz Miklaszewski'
  description 'This plugin automatically creates issues for the specified periodic activity e.g. testing queue.'
  version '1.3.0'
  url 'http://www.gmiklaszewski.pl/redmine_carousel'
  author_url 'http://www.gmiklaszewski.pl'

  project_module :carousels do
    permission :manage_carousels, :carousels => [:new, :create, :edit, :update, :destroy]
  end
end
