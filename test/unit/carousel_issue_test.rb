require File.dirname(__FILE__) + '/../test_helper'

class CarouselIssueTest < ActiveSupport::TestCase
  should_belong_to(:issue)
  should_belong_to(:carousel)
  should_belong_to(:user)
end
