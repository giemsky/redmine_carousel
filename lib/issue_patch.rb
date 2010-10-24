require_dependency 'issue'

# Patches Redmine's Issues dynamically.  Adds a +carousel_issue+ association.
module IssuePatch

  def self.included(klass) # :nodoc:
    klass.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development  
      has_one :carousel_issue, :dependent => :destroy
    end
  end

end