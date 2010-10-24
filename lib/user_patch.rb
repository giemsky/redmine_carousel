require_dependency 'user'

# Patches Redmine's Users dynamically.  Adds a +carousel_issues+ association.
module UserPatch
  
  def self.included(klass) # :nodoc:
    klass.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development  
      has_many :carousel_issues, :dependent => :destroy
    end
  end
  
end