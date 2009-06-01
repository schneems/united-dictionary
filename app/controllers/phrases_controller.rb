class PhrasesController < ApplicationController
 require "openid" 
 require "RMagick"
 
 layout "phrases", :except => [:testing, :testing_too, :testing_three, :google, :gg ]
 
 protect_from_forgery :only => [:create, :update, :destroy] 
 
 cache_sweeper :phrase_sweeper, :only => [:create, :update, :destroy, :rank_it]

 cache_sweeper :definition_sweeper, :only => [:create, :update, :destroy, :rank_it]

 cache_sweeper :child_sweeper, :only => [:create, :update, :destroy, :rank_it]
 
###==============BEFORE YOU UPLOAD====================
    ### CTRL+F "puts"
    ### Reset Mugshots to S3
###===================================================


 ## picture_rabbit
 ## select_box in show
 ## convert index and show to share same partials, woot
 ## write a privacy statement
 ## put mugshots onto individual definitions instead of the phrase
 ## work bugs out of slang game (write tests, not the same thing twice in a row)
 
 

 
 ## cache show pages, only clear on rank_it, add_child, add_def, 
        ## must watch children
 ## search_slang rake to clear duplicate entries in DB
 
 ## debugger && list
 ## logger.debug_variables(binding)
 ## debug "======================"
 
 ## rake squeeze(" ") over entire DB 
 
 ## :conditions => ["word = ?", word] 
 
 ## =====Wish list======
    ## plugin for ranking up and down
    ## write a method that goes through every page in a_z ltr = A - Z (and "All"), all pages

    ##  běn zi and ben zi   
    ## pagination on search with AAS
    

    ## email stuff with openid login duplicate  
    ## disguise picture names
    ## make it impossible to get the same pic twice in the slang game or a picture from the same phrase
    ## Banned Words, Related Words, Alt. Spellings, 
    
    
    
    ## remove double operators ++, **
    ## get variables xx, x2, x 
    ## enable x(y+3) => x*(y+3) make tolerant of operators
        ## xx(y+2) => xx*(y+2)

     
      #  I'm attempting to make a javascript/RoR site that utilizes maxima the free math program. In this thread http://www.ruby-forum.com/topic/177232#777054 I was able to pass information into and out of maxima, but I wasn't able to retrieve the last line, and when running this code multiple times:
      #
      #  max = IO.popen("maxima", "w+")
      #  max.puts "1+1;"
      #  response = max.gets
      #  max.close
      #
      #  I get a new instances (found via ps -A) of  "ttys000    0:00.00 (sbcl)"  every time i run the code. And i can't kill this "sbcl" via "kill pid". 
      #
      #  After a few dozen requests I get this error http://www.pastie.org/380263 
      #
      #  http://pastie.org/380232   
        
    
    def testing
      equation = params[:phrase][:word] if params[:phrase] != nil
      equation = "(1+x)/2" if params[:phrase] == nil 
      @equation = equation + ";"
     # 10.times {torture}
      maxima_test
    end
    
    def torture
      require 'timeout'
      Timeout::timeout(3) do
        max = IO.popen("maxima", "w+")
        max.close
      end
         rescue Timeout::Error    
      sleep 2  
    end
    
    def maxima_test
      require 'timeout'
      Timeout::timeout(3) do
        max = IO.popen("maxima", "w+")
        max.puts "display2d : false;"
        max.puts @equation 
        8.times {max.gets}
        @response = max.gets ## One Line Answer
        @response = @response[6,@response.size-7]
        max.close_write
      end
         rescue Timeout::Error
     #  debugger
    end
    
    
    
    
    def check_if_var_exists(variables)
      require 'timeout'
      Timeout::timeout(3) do
        max = IO.popen("maxima", "w+")
        max.puts "describe(integrate);"
        @variable = max.gets # /(inexact match)/ ## One Line Answer
        
        max.close
      end
        rescue Timeout::Error
    end
    
    def test_for_proper_syntax(equation)
      equation
    end
    

    
    def function
      ## don't forget to chang [:phrase] if you change the model
      search_term = params[:phrase][:word]
      google_search = "http://www.google.com/search?q=" + search_term.to_s.gsub(' ', '+')
      sleep 200
      redirect_to google_search 
    end
          
 
    def I18n_change_language
      language = params[:language][0,2] ## comes in as lowercase
      session[:selected_language] = language
      redirect_to :action => 'index', :subdomain => language
      flash[:notice] = "This feature is still in alpha, please try again later"
    end
 
    def nothing
      
    end
 
 
    def add_child 
      definition_id = params[:definition].to_i      
      word = params[:child][:word]
      second_word = params[:child][:second_word]
      third_word = params[:child][:third_word]
      language = params[:language]
      variety = params[:variety] ## this will be synonym or antonym
      @definition = Definition.find(:first, :include => [:phrase, :children], :conditions => {:id => definition_id})  
      @phrase = @definition.phrase
      @child = @definition.children.new(:word => word, :second_word => second_word, :third_word => third_word, 
                                        :variety => variety, :language => language, :rank => 1)
                                        
      if (simple_captcha_valid?||logged_in?) && @child.valid?
          @child.save  
          @child.populate_all_child_phrases
          flash[:notice] = "#{t 'flash.new_success'} #{t variety.downcase} #{t 'to'}  #{@phrase.word}" 
          redirect_to :action => :show, :word => @phrase.word, :language => @phrase.language
      else    
        @child.errors.add_to_base("#{t 'error.captcha' }") if !simple_captcha_valid? && @child.valid? ##shows when true, whe valid = false, 
       # redirect_to :action => :show, :word => @phrase.word, :language => @phrase.language 
      # render :partial => 'forms/add_child_form'
      array = []
      @child.errors.each{|attr,msg| array << "#{msg}" }
      flash[:notice] = " #{t 'flash.error'} #{t variety.downcase} |#{array}" 
      
       redirect_to :back
       
      end # if (simple_captch)
      
    end #def
    
    
    
 
     def child_language ##GOOD


        @change_child_language = params[:child_language]
            word = params[:word]
            language = params[:language]
            @child_lang = [] << "All"
            definitions_per_page = params[:per_page]||1
            page = params[:page]||1
            @count_start = page.to_i*definitions_per_page.to_i
            @phrase = Phrase.find(:first, :include => [:mugshots, 
                            :comments, :user], :conditions => {:id => params[:phrase]})
                  @definitions = Definition.find(:all, :include => [:user, :children], :conditions => {:phrase_id => @phrase.id})
                  @mugshots = @phrase.mugshots.paginate :page => params[:page], :order => 'rank DESC', :per_page => 4
                  @comments = @phrase.comments
                  @definitions.each {|definition| definition.children.each{|child|  @child_lang << child.language}}
                  @definitions = @definitions.paginate :page => params[:page], :order => 'rank DESC', :per_page => definitions_per_page 
                  @child_lang.uniq!.sort! if !@child_lang.uniq! == nil      
        
        render :partial => 'main/definition_partial'
      end
      
      def show  ##GOOD
          if params[:id] != nil 
              redirect_three_zero_one
          else
              word = params[:word]
              language = params[:language]
           ##expire_fragment(:action => 'show', :word => word, :language => language, :page => params[:page] || 1)   
           @word = word
           @language = language
            unless read_fragment({:word => word, :language => language, :page => params[:page] || 1})
              
                @child_lang = [] << "All"
                definitions_per_page = 5
                @count_start = params[:page].to_i*definitions_per_page
                @phrase = Phrase.find(:first, :include => [:mugshots, 
                                :comments, :user], :conditions => {:word =>
                                word, :language => language})   
                            
                if @phrase == nil                 
                       redirect_three_zero_one 
                else
                      @definitions = Definition.find(:all, :include => [:user, :children], :conditions => {:phrase_id => @phrase.id})
                      @mugshots = @phrase.mugshots.paginate :page => params[:page], :order => 'rank DESC', :per_page => 4
                      @comments = @phrase.comments
                      @definitions.each {|definition| definition.children.each{|child|  @child_lang << child.language}}
                      @definitions = @definitions.paginate :page => params[:page], :order => 'rank DESC', :per_page => definitions_per_page 
                      @child_lang.uniq!.sort! if !@child_lang.uniq! == nil      
                end ## if @phrase == nil 
            end ## cache
          end 
    end #def show
 
 
 
      
      
 

    
 
 
 
 def change_first_language
   @lanugage_over_ride = params[:language]
   render :partial => 'layouts/search_for_second_lang'
 end
 
 
  def orphans 
      @def_need_child = Definition.find(:all, :include => [:children, :phrase], :order => "rank DESC",
                                  :limit => 75 ).select{ |definition| definition.children[0].nil? }
      @def_need_child = @def_need_child+ Definition.find(:all, :include => [:children, :phrase],
                                  :order => "created_at DESC",
                                  :limit => 75 ).select{ |definition| definition.children[0].nil? }                             
      @phrase_need_def = Phrase.find(:all, :include => [:definitions], :order => "rank DESC",
                                  :limit => 75 ).select{ |phrase| phrase.definitions[0].nil? }
     @phrase_need_def = @phrase_need_def+Phrase.find(:all, :include => [:definitions], :order =>
                                    "created_at DESC",
                                    :limit => 75 ).select{ |phrase| phrase.definitions[0].nil? }  
                                    
      @def_need_child = @def_need_child.collect {|definition| definition.phrase} 
                                                                                    
      @def_need_child.uniq!                                                      
      @phrase_need_def.uniq!                                    

     @def_need_child = @def_need_child.sort_by { rand }
     @phrase_need_def = @phrase_need_def.sort_by { rand }
     @def_need_child = @def_need_child.paginate :page => params[:page], :per_page => 5
     @phrase_need_def = @phrase_need_def.paginate :page => params[:page], :per_page => 30
    render  :template => "phrases/orphan"       
 end 
 
 
 def create 
  # params[:phrase]["rank"]=1
  # params[:phrase]["language"]=params[:language]
  # params[:phrase]["word"] = params[:phrase]["word"].strip.squeeze(" ") if params[:phrase]["word"] != nil 
  # params[:phrase]["second_word"] = params[:phrase]["second_word"].strip.squeeze(" ") if params[:phrase]["second_word"] != nil 
  # params[:phrase]["third_word"] = params[:phrase]["third_word"].strip.squeeze(" ") if params[:phrase]["third_word"] != nil 
  # params[:phrase][:new_definition_attributes][0]["rank"] = 1 if params[:phrase][:new_definition_attributes] != nil 
    params[:phrase][:user_id] = current_user if logged_in?
   
   @phrase = Phrase.new(params[:phrase])
        
    if (simple_captcha_valid?||logged_in?) && @phrase.valid?
        @phrase.save  
        flash[:notice] = "#{t 'flash.new_success'} #{t 'phrase' }" 
        redirect_to :action => :show, :word => @phrase.word, :language => @phrase.language
    else    
      @phrase.errors.add_to_base("#{ t 'error.captcha' }") if !simple_captcha_valid? && @phrase.valid? ##shows when true, whe valid = false, 
      @phrase_search = @phrase
      render :template => 'phrases/new_slang'
    end # if (simple_captch)
 end # def
 
 

 def update  ### i don't use this, i don't think
   params[:phrase][:existing_definition_attributes] ||= {} 
   @phrase = Phrase.find(params[:id]) 
   if @phrase.update_attributes(params[:phrase]) 
       flash[:notice] = "Successfully updated phrase and definitions." 
       redirect_to phrase_path(@phrase)
     else 
       render :action => 'edit' 
     end 
 end 
 
 
 
 def existing_definition_attributes=(definition_attributes) 
   definitions.reject(&:new_record?).each do |definition| 
     attributes = definition_attributes[definition.id.to_s] 
     if attributes 
       definition.attributes = attributes 
     else 
       definitions.delete(definition) 
     end 
   end 
 end 
     
   def save_definitions 
     definitions.each do |definition| 
         definition.save(false) 
     end 
   end
 

     
     def definition_browse     
       @phrase = Phrase.find_with_children(params[:phrase])
       @definition = @phrase.definitions[params[:new_index].to_i]       
       render :partial => "main/def_move", :controller => 'phrases'
     end ## go_left



      def update_all_languages ## called in update_second_language and used in edit_second_language_form 
        ## finds phrase with word and language, or creates new one, basically guarantees the phrase doesn't already exist
        
        if @phrase.second_word == nil || @phrase.second_word.empty?
            @phrase.second_word = @second_word ## updates if needed
        else
           @second_word_over_ride = @phrase.second_word
        end ## if @phrase.second_word

        if @phrase.third_word == nil ||@phrase.third_word.empty?
          @phrase.third_word = @third_word ## updates if needed
        else
          @third_word_over_ride = @phrase.third_word
        end ## if @phrase.third_word

        @phrase.save!

        if @phrase.second_word == @second_word || @phrase.third_word == @third_word ## 
            @children = Child.find(:all, :conditions => {:language => @phrase.language, :word => @phrase.word})
          if @children.empty? || @children[0] ==nil
          else
            for child in @children
              child.update_attributes(:second_word => @phrase.second_word, :third_word => @phrase.third_word)
            end ## for child
          end # if @children.empty
        end ## if @phrase.second_word
      end ## def update_all_languages


      def update_second_language
        id = params[:element]
         word = params[:child][:word].strip.squeeze(" ") if params[:child][:word] != nil 
         second_word = params[:child][:second_word].strip.squeeze(" ") if params[:child][:second_word] != nil 
         third_word = params[:child][:third_word].strip.squeeze(" ") if params[:child][:third_word] != nil

         element_class = params[:type].capitalize.constantize
         @element = element_class.find(id)     
         @element.update_attributes(:word => word, :second_word => second_word, :third_word => third_word)
         @element.class == "Child" ? @phrase = @element.definition.phrase : @phrase = @element 

         if (simple_captcha_valid?||logged_in?) && @element.valid?
             @element.save  
             flash[:notice] = " #{t 'flash.update_success' } " 
         else    
              @element.errors.add_to_base("#{t 'errors.captcha'}") if !simple_captcha_valid? && @element.valid? ##shows when true, whe valid = false, 
              array = []
              @element.errors.each{|attr,msg| array << "#{msg}" }
              flash[:notice] = " #{t 'error.saving'} |#{array}" 
         end # if (simple_captch)
        
        redirect_to :back
      end


      def pinyin_form_show ## shows add_pinyin_form
        element_class = params[:type].capitalize.constantize
        @element = element_class.find(params[:element])
        @element.class == "Child" ? @type = @element.variety : @type = @element.class
        @child = @element
        @element.class == "Child" ? @phrase = @element.definition.phrase : @phrase = @element	          
      render :partial => 'forms/add_pinyin_form'
    end
    
    
    def update_create_for_chinese_add_child
      @phrase = Phrase.new
      @default_language = params[:language]
      @child = Child.new(:language => @default_language)
      @search = params[:search]
      @f = params[:form]
      @element = @child
      render :partial => 'forms/add_child_form_partial'
    end
    
    def update_create_for_chinese
      @phrase = Phrase.new
      @default_language = params[:language]
      @child = Child.new
      @search = params[:search]
      @f = params[:form]
      #<ActionView::Helpers::FormBuilder:0x12c4038>
      render :partial => 'forms/slang_form_partial'
    end
    
    
    def add_child_multiple_languages
      @default_language = params[:language]
      @search = params[:search]
      render :partial => 'forms/multiple_child_languages'
    end
    
    
    def change_second_language #GOOD
      @first_language = params[:language]
      @second_language = params[:second_language]
      render :partial => "search"
     end
     
     
   def play_the_game
     language = params[:selectbox]||"English"
     all_mugshots = Mugshot.find(:all, :include => :phrase )
     mugshots = all_mugshots.select{ |mugshot| !mugshot.phrase.nil? && mugshot.phrase.language == language }
     mugshots = mugshots.sort_by { rand }
     mugshots = mugshots[0,4]
     @winning_mugshot  = mugshots[0]
     phrases  = mugshots.collect {|mugshot| mugshot.phrase}
     @winning_phrase = phrases[0] ## this is the right answer
     @pictures = mugshots.sort_by {rand}
     ##find all mugshots, where mugshot.phrase.language == language
   end
     
     
     
    
    def play_the_game_old
      game_phrase = []
      @pictures = []
       
       @game_language = params[:selectbox]||@skip_language||@old_phrase.language
       @all_mugshots = Mugshot.find(:all, :include => :phrase )

       @mugshots = @all_mugshots.select{ |m| !m.phrase.nil? && m.phrase.language == @game_language }
       @mugshots.each {|mugshot| game_phrase << mugshot.phrase}
       @phrase =  game_phrase.sort_by { rand }    
      if @old_phrase != nil && @phrase[0] == @old_phrase
          @phrase = @phrase[1]
        else
          @phrase = @phrase[0]
      end
      
       @pictures =  @all_mugshots.sort_by { rand }    
       @pictures = @pictures[0,3]
       if @phrase != nil 
           all_mugshot_from_phrase = @phrase.mugshots
           @mugshot_from_phrase = all_mugshot_from_phrase.sort_by { rand } 
           @pictures << @mugshot_from_phrase[0]
           @pictures = @pictures.sort_by {rand}
       end ## if @phrase != nil 

       end ## def play_the_game
      
    
    def game_submit
      @winning_phrase = Phrase.find(params[:winning_id])
      @winning_mugshot = Mugshot.find(params[:winning_mugshot])
      @selected_mugshot = Mugshot.find(params[:mugshot_selected])
      
      if @winning_mugshot == @selected_mugshot
        flash[:notice] = "#{t 'flash.correct'}"
      else
        flash[:notice] = "#{t 'flash.incorrect'}"
      end
      
      play_the_game
      render :template => 'game/show'
    end
    
    
    def game_submit_old
      @old_phrase = Phrase.find(params[:winning_id])
      @mugshot = Mugshot.find(params[:mugshot_selected])
      @correct_mugshot = Mugshot.find(params[:correct_mugshot])
        if @correct_mugshot[0] == @mugshot
            flash[:notice] = 'Correct'
        else ## if mugshot
          flash[:notice] = 'Incorrect'
      end ## if correct
          play_the_game
          render :template => 'game/show'
    end ## def game_submit
    
    
    
    def begin_game
        play_the_game
      render :template => 'game/show'
    end ## def begin_game
    
    def slang_game
      @skip_language = params[:language]||"English"
      begin_game
    end
    
    
    
    def picture_add_show
      value = params[:value].to_i
      element_class = params[:type].capitalize.constantize
      @element = element_class.find(value)
      render :template => 'mugshots/new', :layout => false
    end # def picture_add_show
    
    def redirect_three_zero_one
      flash[:notice] = "#{t 'flash.three_zero_one' }"
      headers["Status"] = "301 Moved Permanently"
      redirect_to :action => :index
    end
      
 
    
    def show_child_add ## GOOD
       @phrase = Phrase.find(params[:phrase])
       @definition = @phrase.definitions.find(params[:definition])
          @type = params[:type]
          @child_language = params[:child_language]||@phrase.language
          @child = Child.new(:language => @phrase.language)
          @element = @child
          
        render :partial => "forms/add_child_form", :controller => 'phrases'
     end ## def show_child_add

    

    
    
    
    def user_search
      @user = User.find(params[:id], :include => [:phrases, :definitions])
        @definitions_to_pag = @user.definitions
        @definitions = @definitions_to_pag.paginate :page => params[:page], :order => 'created_at DESC', :per_page => 10
        @phrases_to_pag = @user.phrases
        @phrases = @phrases_to_pag.paginate :page => params[:page], :order => 'created_at DESC', :per_page => 20
      render :template => 'phrases/show_user'
    end
    
    
    def about
      render  :template => "phrases/about"
    end
    
    
    def top_slang
     # expire_fragment(:action => 'top_slang', :page => 1) 
     unless read_fragment({:page => params[:page] || 1})
        @new_phrases = Phrase.find_top(params[:page]||1)
     end
      render  :template => "phrases/top_slang"
    end
    
    
    def recently_added
     ## expire_fragment(:action => 'recently_added', :page => 1)
      unless read_fragment({:page => params[:page] || 1})
          @phrases = Phrase.find(:all,:include => [{:definitions => :children}], :order => 'created_at DESC', :limit => 50)
          @phrases = @phrases.uniq
          if @phrases != nil
            @new_phrases = @phrases.paginate :page => params[:page], :order => 'created_at DESC', :per_page => 5
          end ## if @phrase !=nil
      end
          render  :template => "phrases/recently_added"
    end
    
    
    def top_users
      @users = User.find(:all, :order => 'rank DESC', :limit => 20)
      render  :template => "phrases/top_users"
    end
    
    def orphan
      
      @definitions_array = []
      @children_array = []
      @children = Definition.find(:all, :include => [:children, :phrase], :order => "created_at DESC", :limit => 100 ).select{ |m| m.children[0].nil? }
      @children_rand = Definition.find(:all, :include => [:children, :phrase], :limit => 50, :offset => ( Definition.count * rand ).to_i).select{ |m| m.children[0].nil? }
      @children = @children + @children_rand
      for definition in @definitions
        if definition.class.to_s != "Phrase"
            @definitions_array << definition.phrase
          end
      end
      for definition in @children
        if definition.class.to_s != "Phrase"
            @children_array << definition.phrase
          end
      end
       @children = @children_array
       @definitions = @definitions_array
       @children = @children.sort_by { rand }
       @definitions = @definitions.sort_by { rand }
       @no_children = @children.paginate :page => params[:page], :per_page => 5
       @no_definitions = @definitions.paginate :page => params[:page], :per_page => 20
      
      @new_phrases = @no_children
      render  :template => "main/orphan"
    end
    
    def create_comment
      @phrase = Phrase.find(params[:id])
       if simple_captcha_valid? || logged_in? 
         @phrase.comments.create(:name => params[:comment][:name], :comment_field => params[:comment][:comment_field], :rank => 1)
         redirect_to :action => 'show', :word => @phrase.word, :language => @phrase.language
      else
        flash[:notice] = "#{t 'error.captcha'}"
        redirect_to :action => 'show', :word => @phrase.word, :language => @phrase.language
      end
      
    end
    
    def comment_form_show
      @phrase = Phrase.find(params[:phrase])
      @comment = Comment.new
      render :partial => "forms/comment_form"
    end
    
    def index 
     if request.host == "0.0.0.0"||request.host == "greenerthangoogle.com"||request.host == "www.greenerthangoogle.com"
        redirect_to :action => "google"
      end
      ##expire_fragment(:action => 'index', :page => 1)
      ## expire_fragment(%r{^[^(phrases)]})##maybe stupid this regex finds all files that don't start with phrases
      #  unless read_fragment({:page => params[:page] || 1})
      #     @new_phrases = Phrase.find_top(params[:page]||1)
      #  end        
    end
      
    
    
  def show_delete_form ## GOOD, name is deceptive
    element_class = params[:type].capitalize.constantize
    @element = element_class.find(params[:element])         
      render :partial => "forms/delete_form"
   end
    
    
    
  def mark_element_for_delete ## GOOD
    element_class = params[:type].capitalize.constantize
    @element = element_class.find(params[:element])    
    @element.marked_at = Time.now if @element.marked_at == nil 
        if (simple_captcha_valid?||logged_in?)
                @element.save ! 
                flash[:notice] = " #{t 'flash.ticking' }" 
                redirect_to :back
            else    
                @element.errors.add_to_base("#{t 'error.captcha' }") if !simple_captcha_valid?
                flash[:notice] = "#{t 'error.captcha' }"        
          redirect_to :back
        end
  end  ## def battle_it
    
    
    def show_definition_add
      @phrase = Phrase.find(params[:phrase])
      @uses_redbox = true
      render :partial => "forms/definition_form"
    end
    
  def rank_it ## GOOD
      value = params[:value].to_i
      element_class = params[:type].capitalize.constantize
      @element = element_class.find(params[:element])         
      @element.rank == nil ? @element.rank = 1  : @element.rank += value 
      @element.save!
      @state = params[:rank_to]
      render :partial => 'rank_one'
  end #def rank_it
  
  
  
  
 
  def a_z
  #  expire_fragment(%r{phrases/a_z.*}) ## checked out
    value =  params[:ltr]||"A"
    value = value.strip
    unless read_fragment({:page => params[:page]||1, :ltr => value||"All"})    
        @value = value
        submit_language = params[:a_z_language]||"English"
        lang = params[:a_z_language]||"English"
        @language = lang
      if value == "All" 
          phrases_to_pag = Phrase.find(:all, :conditions => {:language => "English"}, :order => 'word ASC')
          @phrases = phrases_to_pag.paginate :page => params[:page], :order => 'word ASC', :per_page =>  90
     else  
          temp_phrase = []
           phrase_paginator = Phrase.find(:all, 
             :conditions => [ 'LOWER(word) LIKE ?',
              '%' + value.downcase + '%'], 
               :order => 'word ASC') 
           for phrase in phrase_paginator
             if phrase.word[0,1].downcase == value.downcase && phrase.language == submit_language
                temp_phrase << phrase
             end ##if phrase.word
           end ## for phrase in 
         @phrases = temp_phrase.paginate :page => params[:page], :order => 'word ASC', :per_page => 90
        end ##if value == nil
    end # unless 
 end ## def a_z
 
 
 

 def random ##GOOD, need to make language dependent
   phrases = []                          
   phrases = phrases + Phrase.find(:all, :include => [:definitions => :children], :limit => 20, :offset => ( Phrase.count * rand ).to_i)
   phrases = phrases + Phrase.find(:all, :include => [:definitions => :children], :limit => 20, :offset => ( Phrase.count * rand ).to_i)
   phrases = phrases.sort_by { rand }
   if phrases.empty?
     redirect_to :action => :new
   else
       @new_phrases = phrases.paginate :page => params[:page], :per_page => 5
      render  :template => "phrases/random"
   end
 end
 
 def search ## this is what gets called on when you click on a single word
   redirect_three_zero_one
 end
 
 
 def search_slang
   ## this is bad coding, need to change this...somehow escape the cache statement
  # 0.upto(10) do |count|
  #   expire_fragment(:action => 'search_slang', :page => count)
  # end
   query = params[:query]||session[:query] 
   language = params[:language]||session[:first_language]
   second_language = params[:second_language]||session[:second_language]
   query = session[:query] = query.to_s
   language = session[:first_language] = language.to_s
   second_language = session[:second_language]= second_language.to_s
        
   
   @results = []
   @results += Phrase.find(:all, :conditions => ['word like ? AND language =  ?', query, language ]) if second_language == nil || second_language == "" || second_language == "Simplified"||second_language == "All"
   @results += Phrase.find(:all, :conditions => ['second_word like ? AND language = ?', query, language ]) if second_language == "Traditional" || second_language == "All"
   @results += Phrase.find(:all, :conditions => ['third_word like ? AND language  = ?', query, language ])  if second_language == "Pinyin" || second_language == "All"
   
 ###  @results += Phrase.find_by_solr("word:#{query} language:#{language}").results if second_language == nil || second_language == "" || second_language == "Simplified"||second_language == "All"
 #   @results += Phrase.find_by_solr("second_word:#{query} language:#{language}").results if second_language == "Traditional" || second_language == "All"
 #  @results +=  Phrase.find_by_solr("third_word:#{query} language:#{language}" ).results if second_language == "Pinyin" || second_language == "All"
 
   @results.uniq!
   @results = @results.paginate :page => params[:page],  :per_page => 5
   @new_phrases = @results
   if @results.empty?
      @phrase_search = Phrase.new(:word => query, :language => language)
      flash[:notice] = " #{t 'flash.search_one'} #{query}  #{t 'yet' } <br /> #{t 'flash.search_two' } "
      phrase_rescue
   end ## @phrases != nil
   render :template => 'phrases/search_results'
 end ## search_everything
 
 
 def phrase_rescue
   @phrase = Phrase.new
   @phrase.language = params[:language].to_s
   @phrase.word =  params[:query].to_s
 end 
 
 def edit 
   @phrase = Phrase.find(params[:id]) 
 end 
 

 def new
    @phrase = Phrase.new
    @definition = @phrase.definitions.build 
 end #def new
    
    
    

end #class PhrasesController 

  
  
## ixwaxysw http://gegntacy.com opzplmrp abtdkwmz vxvcoxzr [URL=http://yrbcinil.com]zbxuswpm[/URL] 
##  [URL=http://ebzuwptj.com]olxjkfky[/URL] zqldtxre http://owiuaint.com rabfgolh aejsfphj pqnkbpme
##  [URL=http://dpumxkrb.com]fptwtdrm[/URL] imtuqmfh http://aviydtqz.com nfjbbrex zrwdtund gnnplfzk
##  igzrrsyn hbrrcrcc http://jeagafjm.com ywucrauv lfugshfm [URL=http://rfxmbfgb.com]vhcrewxh[/URL] 
##  nvawnopw http://zzstuxsi.com foteefnu lxsroyqs khhjacbu [URL=http://zjwqpyzf.com]wvctjste[/URL]