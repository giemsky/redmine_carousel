require File.dirname(__FILE__) + '/../test_helper'

class CarouselsControllerTest < ActionController::TestCase
  fixtures :projects, :versions, :users, :roles, :members, :member_roles, :issues, :journals, :journal_details,
           :trackers, :projects_trackers, :issue_statuses, :enabled_modules, :enumerations, :boards, :messages,
           :attachments, :custom_fields, :custom_values, :time_entries
  
  # Replace this with your real tests.
  def test_truth
    assert true
  end

end
