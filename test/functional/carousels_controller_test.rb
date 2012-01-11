require File.dirname(__FILE__) + '/../test_helper'

class CarouselsControllerTest < ActionController::TestCase
  fixtures :projects, :versions, :users, :roles, :members, :member_roles, :issues, :journals, :journal_details,
           :trackers, :projects_trackers, :issue_statuses, :enabled_modules, :enumerations, :boards, :messages,
           :attachments, :custom_fields, :custom_values, :time_entries, :issue_categories, :carousels, :carousels_members,
           :carousel_issues

  # Re-raise errors caught by the controller.
  class CarouselsController; def rescue_action(e) raise e end; end

  def self.should_check_autorization(project)
    context '#new' do
      should 'get 302' do
        get :new, :project_id => eval(project)
        assert_response 403
      end
    end

    context '#create' do
      should 'get 302' do
        post :create, :project_id => eval(project)
        assert_response 403
      end
    end

    context '#edit' do
      should 'get 302' do
        get :edit, :project_id => eval(project), :id => eval(project).carousels.first
        assert_response 403
      end
    end

    context '#update' do
      should 'get 302' do
        put :update, :project_id => eval(project), :id => eval(project).carousels.first
        assert_response 403
      end
    end

    context '#destroy' do
      should 'get 302' do
        delete :destroy, :project_id => eval(project), :id => eval(project).carousels.first
        assert_response 403
      end
    end
  end # end should_check_autorization

  context 'any user' do
    setup do
      @user = users(:users_002)
      @project = projects(:projects_001)
      @request.session[:user_id] = @user.id
    end

    context 'carousel module enabled' do
      setup do
        EnabledModule.generate! :project_id => @project.id, :name => 'carousels'
      end

      should_check_autorization('@project')

      context 'user with permission' do
        setup do
          roles(:roles_001).add_permission! :manage_carousels
        end

        context '#new' do
          should 'be successful' do
            get :new, :project_id => @project
            assert_response :success
            assert_template 'carousels/new'
          end
        end

        context '#create' do
          should "should render 'new' template'" do
            post :create, :project_id => @project
            assert_response :success
            assert_template 'carousels/new'
          end
          
          should 'not create new carousel' do
            assert_no_difference('Carousel.count') { post :create, :project_id => @project }
          end

          context 'with valid parameters' do
            setup do
              # TODO: load these values from fixtures
              @carousel_parameters = {
                :name => 'Super Carousel',
                :active => 1,
                :time_period_quantity => 5,
                :time_period_seconds => 3600,
                :member_ids => [2, 3],
								:begin_at => Time.now.tomorrow.to_s(:db),
                :issue_settings => {
                  :subject => 'Carousel Issue Subject',
                  :tracker_id   => trackers(:trackers_001).id,
                  :priority_id  => enumerations(:enumerations_004).id,
                  :category_id  => issue_categories(:issue_categories_001).id,
                  :author_id    => members(:members_001).user_id
                }
              }
            end
            
            should 'redirect' do
              post :create, :project_id => @project, :carousel => @carousel_parameters
              assert_response :redirect
            end

            should 'create new carousel' do
              assert_difference('Carousel.count') { post :create, :project_id => @project, :carousel => @carousel_parameters }
            end
          end # end context with valid parameters
        end # end context #create

        context '#edit' do
          should 'be successful' do
            get :edit, :project_id => @project, :id => carousels(:carousel_001)
            assert_response :success
            assert_template 'carousels/edit'
          end
        end

        context '#update' do
          setup do
            @carousel = carousels(:carousel_001)
          end
          
          should "should render 'edit' template'" do
            put :update, :project_id => @project, :id => @carousel
            assert_response :success
            assert_template 'carousels/edit'
          end

          should 'not update carousel' do
            put :update, :project_id => @project, :id => @carousel
            assert_equal @carousel.attributes, @carousel.reload.attributes
          end

          context 'with valid parameters' do
            setup do
              # TODO: load these values from fixtures
              @carousel_parameters = {
                :name => 'Round Robin',
                :active => 1,
                :time_period_quantity => 5,
                :time_period_seconds => 3600,
                :member_ids => [2, 3],
                :issue_settings => {
                  :subject => 'Carousel Issue Subject',
                  :tracker_id   => trackers(:trackers_001).id,
                  :priority_id  => enumerations(:enumerations_004).id,
                  :category_id  => issue_categories(:issue_categories_001).id,
                  :author_id    => members(:members_001).user_id
                }
              }
            end

            should 'redirect' do
              put :update, :project_id => @project, :id => @carousel, :carousel => @carousel_parameters
              assert_response :redirect
            end

            should 'update carousel' do
              put :update, :project_id => @project, :id => @carousel, :carousel => @carousel_parameters
              assert_equal @carousel_parameters[:name], @carousel.reload.name
            end
          end # end context with valid parameters
        end # end context #update

        context '#destroy' do
          setup do
            @carousel = carousels(:carousel_001)
          end

          should 'destroy carousel' do
            assert_difference('Carousel.count', -1) { delete :destroy, :project_id => @project, :id => @carousel }
          end
          
          should 'redirect' do
            delete :destroy, :project_id => @project, :id => @carousel
            assert_response :redirect
          end
        end # end context #destroy
      end # end context user with permission
    end # end context carousel module enabled

    context 'carousel module disabled' do
      should_check_autorization('@project')
      
      context 'user with permission' do
        setup do
          roles(:roles_001).add_permission! :manage_carousels
        end

        should_check_autorization('@project')
      end # end context user with permission
    end # end context carousel module disabled
  end # end context any user
end
