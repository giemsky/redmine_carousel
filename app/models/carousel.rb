class Carousel < ActiveRecord::Base
  unloadable

  serialize :auto_assign, Hash

  belongs_to :project
  has_and_belongs_to_many :members, :include => [:user, :roles], 
    :conditions => "#{User.table_name}.type='User' AND #{User.table_name}.status=#{User::STATUS_ACTIVE}", :order => "#{Member.table_name}.id"
  has_many :carousel_issues, :dependent => :destroy
  has_many :issues, :through => :carousel_issues
  
  validates_presence_of :name, :project, :begin_at
  validates_numericality_of :period, :greater_or_equal_to => TimePeriod.all.min_by(&:seconds).seconds
  validate :validate_issue_settings
  
  before_save :set_issue_settings
  before_validation :set_period
  
  named_scope :to_run, :conditions => "NOW() > COALESCE(begin_at, '1970-01-01') AND NOW() > ADDDATE(COALESCE(last_run, '1970-01-01'), INTERVAL period SECOND)"
  named_scope :active, :conditions => {:active => true}
  
  def after_initialize
    self.auto_assign ||= Hash.new
  end
  
  def next_run
    self.last_run + self.period
  end
  
  def users_queue
    members.all(:include => :user).map(&:user)
  end
  
  def time_period_seconds=(time_period_seconds)
    @time_period_seconds = time_period_seconds.to_i
  end
  
  def time_period_seconds
    @time_period_seconds ||= TimePeriod.seconds(self.period.to_i)
  end
  
  def time_period_quantity=(time_period_quantity)
    @time_period_quantity = time_period_quantity.to_i
  end
  
  def time_period_quantity
    @time_period_quantity ||= TimePeriod.quantity(self.period.to_i)
  end
  
  def run
    transaction do
      issue = project.issues.create!(
        :assigned_to  =>  next_run_user,
        :author       =>  project.members.find(issue_settings.author_id).user,
        :subject      =>  issue_settings.subject,
        :category     =>  project.issue_categories.find(issue_settings.category_id),
        :tracker      =>  project.trackers.find(issue_settings.tracker_id),
        :priority     =>  IssuePriority.find(issue_settings.priority_id),
        :description  =>  issue_settings.description
      )
      carousel_issues.create!(:issue => issue, :user => issue.assigned_to)
      self.last_run = Time.now
      save!
    end
  end
  
  def issue_settings
    @issue_settings ||= CarouselIssueSettings.new(auto_assign)
  end
  alias_method :carousel_issue_settings, :issue_settings
  
  def issue_settings=(attrs)
    @issue_settings = CarouselIssueSettings.new(attrs)
  end
  alias_method :carousel_issue_settings=, :issue_settings=
  
  def next_run_user
    return nil if users_queue.empty?
    
    last_user_number = users_queue.find_index(last_run_user)
    if last_user_number
      users_queue[(last_user_number + 1) % users_queue.count]
    else
      users_queue[0]
    end
  end
  
  def last_run_user
    return nil if carousel_issues.empty?
    carousel_issues.last.user
  end
  
  private
  
  def set_issue_settings
    self.auto_assign = issue_settings.attributes
  end
  
  def set_period
    self.period = time_period_quantity * time_period_seconds
  end
  
  def validate_issue_settings
    return if issue_settings.valid?
    
    issue_settings.errors.each_full{ |msg| errors.add_to_base(msg) }
  end

end
