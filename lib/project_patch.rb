require_dependency 'project'

# Patches Redmine's Projects dynamically.  Adds a +carousels+ association.
module ProjectPatch

  def self.included(klass) # :nodoc:
    klass.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development  
      has_many :carousels, :dependent => :destroy
    end
  end

end