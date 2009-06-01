class MugshotsController < ApplicationController
  
  
  def delete_element
    @phrase = Phrase.find(params[:id])
    @element = Mugshot.find(params[:element])
    render :partial => "delete_form", :controller => 'mugshots'
  end
  
  

def new
  @phrase = Phrase.find(params[:id])
  @mugshot = @phrase.mugshots.new(:rank => 1)
end

def create
  if simple_captcha_valid?||logged_in?
        value = params[:value].to_i
        element_class = params[:type].capitalize.constantize
        @element = element_class.find(value)
    
        @mugshot = @element.mugshots.new(params[:mugshot])
        @mugshot.rank = 1
#        @mugshot.phrase_id = @phrase.id
        @mugshot.save!
       ## @comment = @mugshot.comments.new(:comment_field =>params[:comment_field], :rank => 1)
           if logged_in?
             if @mugshot.user_id == nil
               @mugshot.update_attributes(:user_id => current_user.id)
      ##         @comment.update_attributes(:name => current_user.login)
             end ## mugshot.user_id
           end ## logged_in?
  
        @phrase = @element
        if @mugshot.save
          flash[:notice] = 'Photo was Successfully Added.'
          redirect_to :action => 'show', :word => @phrase.word , :language => @phrase.language,  :controller => 'phrases'  
        else
          flash[:notice] = 'Captcha Not Correct, You My Good Friend Are a Robot ^_^'
          redirect_to :action => 'show', :word => @phrase.word , :language => @phrase.language, :controller => 'phrases'  
        end ## if
        
      else
        redirect_to :back
        
    end ## if simple_captcha valid
end ##def create

def show
  @mugshots = Mugshot.find(:all, :conditions =>{ :thumbnail => nil })
  
end



end