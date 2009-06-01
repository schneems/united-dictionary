require File.dirname(__FILE__) + '/../test_helper'

class PhrasesControllerTest < ActionController::TestCase
  
  def setup 
    @controller = PhrasesController.new 
    @request = ActionController::TestRequest.new 
    @response = ActionController::TestResponse.new 
  end
  
  def test_index 
    get :index 
    assert_response :success 
  end 
  
  def test_new_slang
    get :new_slang
    assert_response :success
  end
  
  def test_slang_game
    get :slang_game
    assert_response :success
  end
  
  def test_orphans
    get :orphans
    assert_response :success
  end
  
  def test_recently_added
    get :recently_added
    assert_response :success
  end  
 
  def test_random
    get :random
    assert_response :success
  end 
  
  def test_top_users
    get :top_users
    assert_response :success
  end 
  
  def test_download
    get :download
    assert_response :success
  end
  
  def test_a_z
    get :a_z
    assert_response :success
  end    
  
  
#  def test_should_get_index
#    get :index
#    assert_response :success
#    assert_not_nil assigns(:phrases)
#  end
#
#  def test_should_get_new
#    get :new
#    assert_response :success
#  end
#
  def test_should_create_phrase    
    assert_difference('Phrase.count') do
      create_phrase()
    end
    assert_redirected_to :action => :show, :word => 'maguire', :language => "English"
  end
#
#  def test_should_show_phrase
#    get :show, :id => phrases(:one).id
#    assert_response :success
#  end
#
#  def test_should_get_edit
#    get :edit, :id => phrases(:one).id
#    assert_response :success
#  end
#
#  def test_should_update_phrase
#    put :update, :id => phrases(:one).id, :phrase => { }
#    assert_redirected_to phrase_path(assigns(:phrase))
#  end
#
#  def test_should_destroy_phrase
#    assert_difference('Phrase.count', -1) do
#      delete :destroy, :id => phrases(:one).id
#    end
#
#    assert_redirected_to phrases_path
#  end
  
  def test_truth
    assert true
  end
  
  protected
    def create_phrase(options = {})
      puts "protected method"
      post :create, :phrase => { :word => 'maguire', :language => "English"}.merge(options), :language => "English"
    end
end
