require File.dirname(__FILE__) + '/../test_helper'

class MugshotsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:mugshots)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_mugshot
    assert_difference('Mugshot.count') do
      post :create, :mugshot => { }
    end

    assert_redirected_to mugshot_path(assigns(:mugshot))
  end

  def test_should_show_mugshot
    get :show, :id => mugshots(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => mugshots(:one).id
    assert_response :success
  end

  def test_should_update_mugshot
    put :update, :id => mugshots(:one).id, :mugshot => { }
    assert_redirected_to mugshot_path(assigns(:mugshot))
  end

  def test_should_destroy_mugshot
    assert_difference('Mugshot.count', -1) do
      delete :destroy, :id => mugshots(:one).id
    end

    assert_redirected_to mugshots_path
  end
end
