require_dependency 'member'

# Patches Redmine's Members dynamically.  Adds a +carousels_members+ association.
module MemberPatch

  def self.included(klass) # :nodoc:
    klass.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development  
      has_and_belongs_to_many :carousels
    end
  end

end