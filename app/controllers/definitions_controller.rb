class DefinitionsController < ApplicationController
  ##cache_sweeper :definition_sweeper
  
  def create
    @phrase = Phrase.find(params[:phrase])
    @definition_meaning = params[:definition][:meaning]
    @example = params[:definition][:example]
    @part_of_speech = params[:definition][:part_of_speech]
    if simple_captcha_valid?||logged_in? 
          @definition = @phrase.definitions.create(:rank => 1, :meaning =>  @definition_meaning,
                :part_of_speech => @part_of_speech, :example => @example)
        @definition = @definition.user_log(@definition.id, logged_in?, current_user)||@definition
           if @definition.save
             
              redirect_to :action => :show, :controller => 'phrases', :word => @phrase.word, :language => @phrase.language
            else
              
              redirect_to :action => :definition_rescue, :controller => 'definitions', :phrase => @phrase.id, :example => @example, :meaning => @definition_meaning, :part_of_speech => @part_of_speech
              flash[:notice] = 'You, Must Enter A Definition, and A Part of Speech'
           end
     else
          flash[:notice] = 'Captcha Not Correct, try it again'
          redirect_to :action => :definition_rescue, :controller => 'definitions', :phrase => @phrase.id, :example => @example, :meaning => @definition_meaning, :part_of_speech => @part_of_speech
    end ## if captha valid?s
  end # def create
  
  
  
  def definition_rescue
    @phrase = Phrase.find(params[:phrase]||@phrase)
    
    @definition = Definition.new
    @definition.example = params[:example]
    @definition.meaning =  params[:meaning]
    @part = params[:part_of_speech]
    render :template => 'forms/definition_rescue', :layout => 'layouts/phrases'
  end
  
  
  
end