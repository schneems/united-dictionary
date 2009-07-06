class UsersController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem
  layout 'phrases'
  # Protect these actions behind an admin login
  # before_filter :admin_required, :only => [:suspend, :unsuspend, :destroy, :purge]
  before_filter :find_user, :only => [:suspend, :unsuspend, :destroy, :purge]



  
  def no_spam
    email = params[:email]
    site = params[:site]
    digest = Digest::SHA1.hexdigest( email+site)
    @no_spam =  digest+"@whyspam.me"
  end
  
  def show_definitions
    @definitions_to_pag = current_user.definitions.find(:all)
    @definitions = @definitions_to_pag.paginate :page => params[:page], :order => 'created_at DESC', :per_page => 10
  end
  
  def show_phrases
    @phrases_to_pag = current_user.phrases.find(:all)
    @phrases = @phrases_to_pag.paginate :page => params[:page], :order => 'created_at DESC', :per_page => 10
  end
  
  
  def update_login
    @user = User.find(params[:id])
    @name = params[:user][:login]
    @email = params[:user][:email]
    @user.login = @name||current_user.login
    @user.email = @email||current_user.email
    if @user.crypted_password == nil
      alphabet = ['a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v']
      alphabet = alphabet.sort_by { rand }
      part_a = rand(1000)
      part_b = alphabet[2]
      part_c = rand(1000)
      part_d = alphabet[10]
      @random_password = "#{part_a}#{part_b}#{part_c}#{part_d}"
      @user.email = "please update your email"
      @user.password = @random_password
      @user.password_confirmation = @random_password
    end
    @user.save!
    redirect_to :action => 'show'
  end
  
  def login_exists 
    @name = params[:name]
    user = User.find(:first, :conditions => {:login => @name})
    if user == nil
     render :text => 'Available'
    else
      render :text => 'Taken, choose another name'
    end #if
  end
  
  def show
    @user = current_user
      @definitions_to_pag = @user.definitions.find(:all)
      @definitions = @definitions_to_pag.paginate :page => params[:page], :order => 'created_at DESC', :per_page => 10
      @phrases_to_pag = @user.phrases.find(:all)
      @phrases = @phrases_to_pag.paginate :page => params[:page], :order => 'created_at DESC', :per_page => 20
      phrase_count = @user.phrases.count||0
      definition_count = @user.definitions.count||0
      children_count = @user.children.count||0
      pictures_count = @user.mugshots.count||0
      extra = @user.extra_rank||0
      @user.rank = phrase_count+definition_count+children_count+pictures_count+extra
      @user.save!
  end
  
  
  def show_profile_email
     render :partial => 'profile_email'
   end
  
  def show_profile_login
    render :partial => 'profile_login'
  end

  # render new.rhtml
  def new
  end

  def create
    cookies.delete :auth_token
    # protects against session fixation attacks, wreaks havoc with 
    # request forgery protection.
    # uncomment at your own risk
    # reset_session
    if simple_captcha_valid? 
        @user = User.new(params[:user])
        @user.register! if @user.valid?
        if @user.errors.empty?
          self.current_user = @user
          flash[:notice] = "Thanks for signing up!"
          @user.extra_rank = 1
          redirect_to :action => 'show'
        else 
          render :action => 'new'
        end ## @user.errors.empty
    else 
      flash[:notice] = 'Captcha Not Correct, You My Friend. Clearly Must be a Robot!' 
      render :action => 'new'
    end # simple_captcha_valid?
  end

  def activate
    self.current_user = params[:activation_code].blank? ? false : User.find_by_activation_code(params[:activation_code])
    if logged_in? && !current_user.active?
      current_user.activate!
      flash[:notice] = "Signup complete!"
    end
    redirect_back_or_default('/')
  end

  def suspend
    @user.suspend! 
    redirect_to users_path
  end

  def unsuspend
    @user.unsuspend! 
    redirect_to users_path
  end

  def destroy
    @user.delete!
    redirect_to users_path
  end

  def purge
    @user.destroy
    redirect_to users_path
  end
  


protected
  def find_user
    @user = @user||User.find(params[:id])
  end

end
