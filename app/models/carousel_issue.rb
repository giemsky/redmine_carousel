class CarouselIssue < ActiveRecord::Base
  unloadable
  
  belongs_to :issue
  belongs_to :carousel
  belongs_to :user
end
