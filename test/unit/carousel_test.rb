require File.dirname(__FILE__) + '/../test_helper'

class CarouselTest < ActiveSupport::TestCase
  fixtures :carousels, :projects, :trackers, :enumerations, :issue_categories, :trackers, :projects_trackers,
           :members, :carousels_members, :carousel_issues, :users, :issue_statuses

  should_validate_presence_of(:name)
  should_validate_presence_of(:project)
	should_validate_presence_of(:begin_at)
  
  should_have_many(:carousel_issues)
  should_have_many(:issues)
  should_belong_to(:project)
  should_have_and_belong_to_many(:members)
  
  should 'have active scope' do
    expected_options = { :conditions => { :active => true } }
    assert_equal expected_options, Carousel.active.proxy_options
  end
  
  should 'have to_run scope' do
    expected_options = { :conditions => "NOW() > COALESCE(begin_at, '1970-01-01') AND NOW() > ADDDATE(COALESCE(last_run, '1970-01-01'), INTERVAL period SECOND)" }
    assert_equal expected_options, Carousel.to_run.proxy_options
  end

	# TODO: be more specific
	def test_to_run_scope
		# last_run & begin_at in the past
		assert Carousel.to_run.include?(carousels(:carousel_003))

		# no last_run, begin_at in the past
		assert Carousel.to_run.include?(carousels(:carousel_004))

		# no last_run, begin_at in the future
		assert !Carousel.to_run.include?(carousels(:carousel_005))
	end
  
  context 'save' do
    setup do
      @carousel = Carousel.create!(:project => projects(:projects_001), 
                                   :name => 'My Carousel',
																	 :begin_at => Time.now,
                                   :time_period_quantity => 5, 
                                   :time_period_seconds => 3600,
                                   :issue_settings => {
                                     :tracker_id   => trackers(:trackers_001).id,
                                     :subject      => 'Issue subject',
                                     :priority_id  => enumerations(:enumerations_004).id,
                                     :category_id  => issue_categories(:issue_categories_001).id,
                                     :author_id    => members(:members_001).user_id
                                     }
                                   )
    end
    
    should 'set period' do
      assert_equal 5*3600, @carousel.period
    end
    
    should 'set issue settings' do
      assert_instance_of Hash, @carousel.auto_assign
      assert_instance_of CarouselIssueSettings, @carousel.issue_settings
      assert_equal 5,  @carousel.issue_settings.keys.size
    end
    
    should 'validate issue settings' do
      @carousel.issue_settings = {}
      assert !@carousel.valid?
      assert 4, @carousel.errors.count
    end
  end # end context save
  
  context 'next run' do
    should 'equal last_run + period' do
      assert_equal Time.parse('2010-09-22 01:00:00'), carousels(:carousel_001).next_run
    end
  end

  context 'any carousel' do
    setup do
      @carousel = carousels(:carousel_001)
      @settings = {
                   :tracker_id   => trackers(:trackers_001).id,
                   :subject      => 'Issue subject',
                   :priority_id  => enumerations(:enumerations_004).id,
                   :category_id  => issue_categories(:issue_categories_001).id,
                   :author_id    => members(:members_001).user_id
                   }
      @carousel.issue_settings = @settings
      @carousel.save!
    end

    context 'members' do
      should 'return only active members' do
        assert_equal "#{User.table_name}.type='User' AND #{User.table_name}.status=#{User::STATUS_ACTIVE}",
          @carousel.members.conditions
      end
    end

    context 'time period seconds setter' do
      should 'set time period seconds' do
        @carousel.time_period_seconds = 100
        assert_equal 100, @carousel.instance_variable_get(:@time_period_seconds)
      end
    end

    context 'time period seconds accessor' do
      should 'return set value if set' do
        @carousel.time_period_seconds = 100
        assert_equal 100, @carousel.time_period_seconds
      end
      
      should 'return period based value if not set' do
        assert_equal 3600, @carousel.time_period_seconds
      end
    end

    context 'time period quantity setter' do
      should  'set time period quantity variable' do
        @carousel.time_period_quantity = 10
        assert_equal 10, @carousel.instance_variable_get(:@time_period_quantity)
      end
    end

    context 'time period quantity accessor' do
      should 'return set value if set' do
        @carousel.time_period_seconds = 100
        assert_equal 100, @carousel.instance_variable_get(:@time_period_seconds)
      end

      should 'return period based value if not set' do
        assert_equal 2, @carousel.time_period_quantity
      end
    end

    context 'issue settings accessor' do
      should 'return carousel issues if set' do
        settings = {:subject => 'Issue subject'}
        @carousel.issue_settings = settings
        assert_equal(settings, @carousel.issue_settings)
      end
      
      should 'return carousel issues from database if not set' do
        assert_instance_of CarouselIssueSettings, @carousel.issue_settings
        assert !@carousel.issue_settings.empty?
      end
    end # end context settings accessor

    context 'issue settings setter' do
      should 'set issue settings variable' do
        settings = {:subject => 'Issue subject'}
        @carousel.issue_settings = settings
        assert_equal settings, @carousel.instance_variable_get(:@issue_settings)
      end
      
      should 'return auto_assign based value if not set' do
        assert_equal Carousel.find(@carousel.id).issue_settings.to_hash, @settings
      end
    end

    context 'run' do
      should 'create new issue' do
        assert_difference('Issue.count') { @carousel.run }
      end

      should 'create new carousel issue' do
        assert_difference('CarouselIssue.count') { @carousel.run }
      end

      should 'set last run to now' do
        @carousel.run
        assert_equal Date.today, @carousel.last_run.to_date
      end

      should 'create issue with settings equal to issue settings' do
        @carousel.run
        issue = @carousel.issues.last
        
        assert_equal @carousel.project, issue.project
        assert_equal @carousel.issue_settings.tracker_id, issue.tracker_id
        assert_equal @carousel.issue_settings.author_id, Member.find(issue.author_id).user_id
        assert_equal @carousel.issue_settings.subject, issue.subject
        assert_equal @carousel.issue_settings.category_id, issue.category_id
        assert_equal @carousel.issue_settings.priority_id, issue.priority_id
        assert_equal @carousel.issue_settings.description, issue.description
      end

      should 'fail if issue settings invalid' do
        @carousel.issue_settings = {}
        assert_raise(ActiveRecord::RecordNotFound) { @carousel.run }
      end
    end # end run context

    context 'users queue' do
      should 'be array' do
        assert_instance_of Array, @carousel.users_queue
      end

      should 'return users for carousel with members' do
        assert_equal 2, @carousel.users_queue.size
      end

      should 'be empty for carousel without members' do
        assert carousels(:carousel_003).users_queue.empty?
      end
    end # end context users queue
  end # end context any carousel
  
  context 'next run user' do
    should 'be nil if users queue empty' do
      assert_nil carousels(:carousel_003).next_run_user
    end

    should 'be next user if users queue is not finished' do
      assert_equal users(:users_003), carousels(:carousel_001).next_run_user
    end
    
    should 'be the first users in the queue if users queue is finished' do
      assert_equal users(:users_002), carousels(:carousel_002).next_run_user
    end
  end # end context next run user
  
  context 'last run user' do
    should 'be nil if no carousel issue was created' do
      assert_nil carousels(:carousel_003).last_run_user
    end

    should 'return user from the last carousel issue' do
      assert_equal carousel_issues(:carousel_issue_001).user, carousels(:carousel_001).last_run_user
    end
  end # end context last run user
end
