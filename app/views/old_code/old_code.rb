class PhrasesController < ApplicationController
 layout "phrases", :except => [:testing, :aas]
 require "openid" 
 require "RMagick"
 
 protect_from_forgery :only => [:create, :update, :destroy] 
 
 cache_sweeper :phrase_sweeper, :only => [:create, :update, :destroy, :rank_it]
 
 ## =====Wish list======
     ## custom validation for captcha
     ## plugin for ranking up and down


## elsif exists


    ## write a method that goes through every page in a_z ltr = A - Z (and "All"), all pages
    ## click on item to search is messed up use restful search instead
    ##  běn zi and ben zi   
    ## pagination on search with AAS
 
    ## rebuild orphans, link to on main page

    ## add alternate spellings
    ## add related words 
 

    ## email stuff with openid login duplicate  
    ## disguise picture names
    ## make it impossible to get the same pic twice in the slang game
    ## or a picture from the same phrase
    ## Banned Words, Related Words, Alt. Spellings,     
         

     
     def include_definition #
       render :partial => 'forms/definition_partial'
     end
     
     
     def go_left
       phrase_id = params[:phrase]
       def_id =  params[:definition].to_i
       @phrase = Phrase.find_with_children(phrase_id)
       @definition = Definition.find_with_children(def_id)
       count = 0
       for definition in @phrase.definitions
          if definition.id == def_id      
             @definition = @phrase.definitions[count-1]
           end ## if definition.id
        count += 1
        end ## for definition
       render :partial => "main/def_move", :controller => 'phrases'
     end ## go_left
     
     
     
     def go_right
       phrase_id = params[:phrase]
       def_id =  params[:definition].to_i
       @phrase = Phrase.find_with_children(phrase_id)
       @definition = Definition.find_with_children(def_id)   
       count = 0
       for definition in @phrase.definitions
          if definition.id == def_id      
             @definition = @phrase.definitions[count+1]   
           end ## if definition.id
        count += 1
         end
       render :partial => "main/def_move", :controller => 'phrases'
     end
     
     



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


      def update_second_language ## called while edit_second_language_form is creating a new phrase with multiple languages, 
                                  ## or updating an allready existing phrase
        
         @phrase = Phrase.find(params[:phrase])
         if simple_captcha_valid? || logged_in? 

              if @phrase.id != params[:element].to_i
                  @element = Child.find(params[:element])
              else 
                  @element = @phrase
              end
              
                second_word = params[:second_word]
                
                if second_word != nil
                  @second_word = second_word[0]
                end
                third_word = params[:third_word]
                
                if third_word != nil
                  @third_word = third_word[0]
                end
                
                @phrase = Phrase.find(:first, :conditions =>{ :word => @element.word, :language => @element.language})||Phrase.create(:rank => 1,
                                      :word => @element.word , :second_word => @second_word, 
                                      :third_word => @third_word, 
                                      :language => @element.language)
           update_all_languages     
            
        else  
           flash[:notice] = 'Captcha Not Correct'
        end #simple_captcha_valid 
        redirect_to :action => :show, :id => params[:phrase], :controller => 'phrases' 
      end # def update_second_language

      def add_second_language ## shows second_language form
        @phrase = Phrase.find(params[:phrase])
        if @phrase.id != params[:element].to_i
            @element = Child.find(params[:element])
        end
      render :partial => 'forms/edit_second_language_form'
    end
    
    
    def add_slang_multiple_languages
      @over_ride = params[:language]
      @search = params[:search]
      
      render :partial => 'forms/multiple_language_form'
    end
    
    
    def add_child_multiple_languages
      @over_ride = params[:language]
      @search = params[:search]
      
      render :partial => 'forms/multiple_child_languages'
      
    end
    
    

    
    def change_first
       @first_language = params[:language]
        if @first_language == "Chinese"
           @second_language = "Simplified"
         end
         if @first_language == "Greek"

         end
         if @first_language == "Japanese"

         end
         if @first_language == "Korean"

         end                       
         if @first_language == "Russian"

         end
         if @first_language == "Chinese"

         end
    end ## def change_first
      
    
    def change_first_language #GOOD
      @over_ride = params[:language]
      @second_language = params[:second_language]
       render :partial => "layouts/second_language_search", :language => params[:language] 
     end
    
    def change_second_language #GOOD
      @first_language = params[:language]
      @second_language = params[:second_language]
       render :partial => "search"
     end
    
    def play_the_game
       language = params[:selectbox]||@skip_language||@old_phrase.language
       @game_language = language
       @mugshots = Mugshot.find(:all, :include => :phrase)
       @mugshots = @mugshots.select{ |m| !m.phrase.nil?  }
       @mugshots = @mugshots.select{ |m| m.phrase.language == @game_language}
       game_phrase = []

      @phrase = game_phrase.sort_by { rand }
      if @old_phrase != nil && @phrase[0] == @old_phrase
          @phrase = @phrase[1]
        else
          @phrase = @phrase[0]
      end
       all_mugshots = Mugshot.find(:all, :conditions =>{ :thumbnail => nil })
       @pictures = []
       @pictures =  all_mugshots.sort_by { rand }    
       @pictures = @pictures[0,3]
       if @phrase != nil 
           all_mugshot_from_phrase = @phrase.mugshots
           @mugshot_from_phrase = all_mugshot_from_phrase.sort_by { rand } 
           @pictures << @mugshot_from_phrase[0]
           @pictures = @pictures.sort_by {rand}
       end ## if @phrase != nil 
      end ## def play_the_game
      
    
    def game_submit
      @old_phrase = Phrase.find(params[:id])
      @mugshot = Mugshot.find(params[:mugshot])
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
      @phrase = Phrase.find(params[:id])
         render :template => 'mugshots/new', :layout => false
    end # def picture_add_show
    
      def show  ##GOOD
            word = params[:word]
            language = params[:language]
             @phrase = Phrase.find(:first, :include => [{:definitions => :children}, :mugshots, 
                            :comments], :conditions => {:word =>
                            word, :language => language})
            @mugshots = @phrase.mugshots.find(:all, :conditions =>{ :thumbnail => nil })
            @mugshots = @mugshots.paginate :page => params[:page], :order => 'rank DESC', :per_page => 4
          @language_array = []
          @child_lang = []
          
          for definition in @phrase.definitions
               children = definition.children 
                  children.each do |element|
                     @child_lang << element.language
                     if element.language == @phrase.language
                       @default_child_language = element.language   
                     end ## if element.language
                   end ## children.each do
          end # for definition
          @add_child_language = params[:child_language]
           @child_controller_language = "All"||@add_child_language||@default_child_language||@child_lang[0]

          @child_lang.uniq!
          respond_to do |format|
            format.html # show.html.erb
            format.xml  { render :xml => @phrase }
        end
    end #def show
    
    def check_for_delete # GOOD
      if @item.marked_at != nil && Time.now-@item.marked_at > 1800
        if @item.rank > -1
          @item.marked_at = nil
          @item.save!
        end
        if @item.rank < 0 && @item.rank != nil
          @item.destroy
        end # if @item.rank > 1
      end # if @item.marked_at
    end #def check_for delete
    
    
    def show_child_add ## GOOD
       @phrase = Phrase.find(params[:phrase])
       @definition = @phrase.definitions.find(params[:definition])
          @type = params[:type]
          @child_language = params[:child_language]||@phrase.language
        render :partial => "forms/add_child_form", :controller => 'phrases'
     end ## def show_child_add
    
    
    
    def add_child ## GOOD
      phrase_id = params[:phrase].to_i
      if simple_captcha_valid?||logged_in? ## then you may add something
          @phrase = Phrase.find(phrase_id)
           word = params[:word][:nil]
           second_word = params[:second_word]
             if second_word != nil
               @second_word = second_word[:nil]
             end ## if
             third_word = params[:third_word]
             if third_word != nil
               @third_word = third_word[:nil]
             end ## if 
           language = params[:language]
           first_letter = word[0,1]
           definition_id = params[:definition].to_i
           variety = params[:variety]
           @variety = variety ## clean plz
               if word.empty?||first_letter == " "
                  redirect_to :action => :show, :word => @phrase.word, :language => @phrase.language
                  flash[:notice] = 'Hey genius, write something in the box before you submit <br/> BTW words must not start with a blank space'
               else 
                 @definition = @phrase.definitions.find(definition_id)
                 authentication_is = @phrase.authenticate(@phrase, @definition, word , language)
                     if authentication_is == true 
                        @phrase_over_ride = Phrase.find(:first, :conditions => {:word => word, :language => language})
                        @phrase = @phrase_over_ride
                              if @phrase_over_ride != nil
                                update_all_languages
                              end ##  if @phrase_over_ride
                          @second_word = @second_word_over_ride||@second_word
                          @third_word = @third_word_over_ride||@third_word
                          
                          @recently_created = @definition.children.create(:rank => 1, :variety => variety, :word => word.downcase, 
                                          :second_word => @second_word, :third_word => @third_word, 
                                          :language => language)
                          @recently_created = @recently_created.user_log(@recently_created.id, logged_in?, current_user)|| @recently_created
                          @recently_created.save!   
                          @phrase = Phrase.find(phrase_id)
                          slang_rabbit
                      else 
                           @add_child_language = language
                           flash[:notice] = 'This word is allready a part of this entry, if you dont like something, rank it down'  
                     end # if authentication == true
                     @add_child_language = language
                 redirect_to :action => :show, :word => @phrase.word, :language => @phrase.language, :child_language => @add_child_language
                 ## xxxschneemanxxx
              end #iword.empty?||first_letter == " " 
      else
          @phrase = Phrase.find(phrase_id)
          flash[:notice] = 'Captcha Not Correct, You My Friend. Clearly Must be a Robot! ^_^'
          redirect_to :action => :show, :word => @phrase.word, :language => @phrase.language
      end ## if captcha correct?
     end ## def add_child
    
    
    def add_slang
      key_arrays =  params[:phrase].keys
      for key in key_arrays
        if key.to_s == "word"
          word = params[:phrase][:word]
        end
        if key.to_s == "second_word"
          word = params[:phrase][:second_word]
          @second_word = second_word
        end
        if key.to_s == "third_word"
          word = params[:phrase][:third_word]
          @third_word = third_word
        end                
      end
      
      
      
        if true #simple_captcha_valid?||logged_in?
          
          
          language = params[:language]
        @found = Phrase.find(:first, :conditions=> {:word => word, :language => language })||nil
        @new_phrase = word
        @first_letter = @new_phrase[0,1]
        if (word==nil||word.empty?||@found!=nil)||@first_letter == " "
          if @found != nil
              @phrase = @found
              update_all_languages       
              redirect_to :action => :show, :word => @phrase.word, :language => @phrase.language
              flash[:notice] = 'This word is allready a part of slangasaurus'
            else
             flash[:notice] = 'Type your question in the box, BTW First Letter of word cannot be blank'
             redirect_to :action => 'ask_for_slang', :language => params[:language]
          end # if @found != nil           
        else
          
          @phrase = Phrase.create(:rank => 1, :word => word.downcase, :second_word => @second_word,
                                  :third_word => @third_word,
                                  :language => params[:language])
          @phrase.save!
          @phrase = @phrase.user_log(@phrase.id, logged_in?, current_user)||@phrase
          respond_to do |format|
            if @phrase.save!
              flash[:notice] = 'Phrase was successfully created, now someone can define and, theasaurize it'
              format.html { redirect_to(@phrase)}
              format.xml  { render :xml => @phrase, :status => :created, :location => @phrase }
            else
              format.html { render :template => 'main/new_slang', :language => params[:language], :search => word  }
              format.xml  { render :xml => @phrase.errors, :status => :unprocessable_entity }
           end #respond_to
          end #if @phrase.save
        end # if all that shit above
      else
            flash[:notice] = 'Captcha Not Correct, You My Good Friend. Clearly Must be a Robot! ^_^'
            render :template => 'main/new_slang', :language => params[:language], :search => word
        end ## if captcha is valid

    end
    
    
    def ask_for_slang
      @phrase = Phrase.new
       render :template => 'main/new'
    end
    
    def user_search
      @user = User.find(params[:id], :include => [:phrases, :definitions])
        @definitions_to_pag = @user.definitions
        @definitions = @definitions_to_pag.paginate :page => params[:page], :order => 'created_at DESC', :per_page => 10
        @phrases_to_pag = @user.phrases
        @phrases = @phrases_to_pag.paginate :page => params[:page], :order => 'created_at DESC', :per_page => 20
      render :template => 'main/show_user'
    end
    
    
    def about
      render  :template => "main/about"
    end
    
    def top_slang
     # expire_fragment(:action => 'top_slang', :page => 1) 
      unless read_fragment({:page => params[:page] || 1})
         @new_phrases = Phrase.find_top(params[:page]||1)
      end
      render  :template => "main/top_slang"
    end
    
    def recently_added
      unless read_fragment({:page => params[:page] || 1})
          @phrases = Phrase.find(:all,:include => [{:definitions => :children}], :order => 'created_at DESC', :limit => 50)
          @phrases = @phrases.uniq
          if @phrases != nil
            @new_phrases = @phrases.paginate :page => params[:page], :order => 'created_at DESC', :per_page => 5
          end ## if @phrase !=nil
      end
          render  :template => "main/recently_added"
      
    end
    
    
    def top_users
      @users = User.find(:all, :order => 'rank DESC', :limit => 20)
      render  :template => "main/top_users"
    end
    
    
    def find_orphans
      @definitions_array = []
      @children_array = []
      @definitions = Definition.find(:all, :include => [:phrase], :conditions => {:meaning => 'This is a temporary definition, think you could do better, hotshot?'})
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
    end
    
    def orphan
      find_orphans
      @new_phrases = @no_children
      render  :template => "main/orphan"
    end
    
    def create_comment
      @phrase = Phrase.find(params[:id])
       if simple_captcha_valid? || logged_in? 
         @phrase.comments.create(:name => params[:comment][:name], :comment_field => params[:comment][:comment_field], :rank => 1)
         redirect_to :action => 'show', :word => @phrase.word, :language => @phrase.language
      else
        flash[:notice] = 'Captcha Failed'
        redirect_to :action => 'show', :word => @phrase.word, :language => @phrase.language
      end
      
    end
    
    def show_comment_add
      @phrase = Phrase.find(params[:phrase])
      @comment = Comment.new
      render :partial => "comment"
    end
    
    def index   
 #expire_fragment(:action => 'index', :page => 1)
 # pages/45/notes
 
## expire_fragment(%r{^[^(phrases)]})##maybe stupid this regex finds all files that don't start with phrases
 

        unless read_fragment({:page => params[:page] || 1})
           @new_phrases = Phrase.find_top(params[:page]||1)
        end        
    end
    
    
    
    def slang_rabbit ##GOOD, wow
      @def_id = @recently_created.definition_id 
      @definition = Definition.find(@def_id) ## definition of parent
      @language = @recently_created.language ## language of child just added
     ## @phrase_id = @definition.phrase_id
     ## @phrase = Phrase.find(@phrase_id)
      @recently_created_phrase = Phrase.find(:first, 
                 :conditions=>{:word => @recently_created.word,
                 :language => @recently_created.language})||Phrase.create(:rank => 1,
                 :word => @recently_created.word , :second_word => @recently_created.second_word, :third_word => @recently_created.third_word, 
                 :language => @recently_created.language) ## phrase created by new child
      @recently_created_phrase = @recently_created_phrase.user_log(@recently_created_phrase.id, logged_in?, current_user)||@recently_created_phrase
       if @variety.to_s.downcase == "antonym" || @recently_created_phrase.created_at-Time.now > 30240
         ## do nothing
         ## this means that the child just added was an antonym
       else
          @recently_created_definition = @recently_created_phrase.definitions.find(:first,:conditions=> 
                                    {:meaning => @definition.meaning})||@recently_created_phrase.definitions.create(:rank => 1, :meaning => 
                                    @definition.meaning, :part_of_speech => @definition.part_of_speech,
                                    :example => @definition.example)
        ## @recently_created_definition = @definition.user_log(@recently_created_definition.id, logged_in?, current_user)||@recently_created_definition
          @recently_created_child = @recently_created_definition.children.find(:first, :conditions => {:word => @phrase.word,
                                      :rank => 1, :language => @phrase.language })||@recently_created_definition.children.create(
                                      :word => @phrase.word, :second_word => @phrase.second_word, :third_word => @phrase.third_word, 
                                      :rank => 1, :language => @phrase.language, :variety => @variety )
                                                                            
        # This part takes existing phrases, and adds new words while making them phrases if they are not allready
                for child in @definition.children
                  if child.variety.downcase == 'antonym'
                    
                    else
                    
                   ## populates recently created Phrase with current synonyms
                    @child = child
                    @authentication_is = @recently_created_phrase.authenticate(@recently_created_phrase, @recently_created_definition, @child.word.to_s, @child.language.to_s )
                    if @authentication_is == true
                       @save_me =  @recently_created_definition.children.create(:rank => 1, :variety => @child.variety, :word => @child.word, 
                                                                          :second_word => @child.second_word,  :third_word => @child.third_word,  
                                                                          :language => @child.language)
                    end #if
                  ## this section finds the phrases that should allready exist and populates them with the new word
                  ## more specifically this part finds the exising phrase and definition, and just incase it can't, creates them   
                    @existing_phrase = Phrase.find(:first, :conditions => {:word => @child.word, :language => @child.language})||
                                           Phrase.create( :rank => 1,  :word => @child.word,:second_word => @child.second_word, 
                                            :third_word => @child.third_word,  :language => @child.language)
                    @existing_definition = @existing_phrase.definitions.find(:first, :conditions => {:meaning => @definition.meaning})||
                                               @existing_phrase.definitions.create( :rank => 1, :meaning => @definition.meaning, 
                                              :part_of_speech => @definition.part_of_speech, 
                                              :example => @definition.example)
                 ## This is the meat and potatoes of the whole shebang
                    @authentication_is = @existing_phrase.authenticate(@existing_phrase, @existing_definition, @recently_created.word,  @recently_created.language )
                       if @authentication_is == true
                         @save_me =  @existing_definition.children.create( :rank => 1, :variety => @recently_created.variety, :word => @recently_created.word,
                                                                            :second_word => @recently_created.second_word,  :third_word => @recently_created.third_word,  
                                                                            :language => @recently_created.language )
                       end # if authentication
                end #for
              
                
                
              end # if not an antonym
            end # if equals antonym
      end #def slang_rabbit 
    
    
    
  def destroy
  end
   
    
  def battle_it ## GOOD
    @phrase = Phrase.find(params[:phrase])
    type = params[:type]
    if type.to_s =="Phrase"
       if @phrase.marked_at == nil
                @phrase.marked_at = Time.now 
                @phrase.save!
            end #if @phrase.marked_at
      end ## if type == "phrase"
      
       if type.to_s == "Comment"
        @comment = @phrase.comments.find(params[:child])
         if @comment.marked_at == nil
            @comment.marked_at = Time.now 
            @comment.save!
         end #if @definition.marked_at     
       end # if comment
    
        if type.to_s == "Definition"
            @definition = @phrase.definitions.find(params[:definition])
             if @definition.marked_at == nil
                @definition.marked_at = Time.now 
                @definition.save!
             end #if @definition.marked_at 
        end # if definition
             
      if type.to_s == "synonym"|| type.to_s == "antonym"
        @definition = @phrase.definitions.find(params[:definition])
          @child = @definition.children.find(params[:child])
            # diference in seconds
          if @child.marked_at == nil
            @child.marked_at = Time.now 
            @child.save!
          end #if @child.marked_ad == nil
      end ## if type.to_s == "Definition"
      
      sleep 0.25
       flash[:notice] = 'Make It So!! The Clock is Ticking!'
       # !!!!
        @child_controller_language = params[:child_language]
    redirect_to :action => :show, :word => @phrase.word, :language => @phrase.language
  end  ## def battle_it
    
    
    def show_definition_add
      @phrase = Phrase.find(params[:phrase])
      @uses_redbox = true
      render :partial => "forms/definition_form"
    end
    
    
   def delete_element ## GOOD, name is deceptive
     type = params[:type].to_s.downcase
     @phrase = Phrase.find(params[:phrase])
     if type == "phrase"
       @element = @phrase
      else
         if type == "definition"
           @definition = @phrase.definitions.find(params[:definition])
           @element = @definition
         end
         if type == "synonym"|| type == "antonym"
           @definition = @phrase.definitions.find(params[:definition])
            @child = @definition.children.find(params[:child])
            @element = @child
        end  ### if type == "definition"
        if type == "comment"
            @comment = @phrase.comments.find(params[:child])
            @element = @comment
        end
        
       end ##if type == phrase    
       
       render :partial => "forms/delete_form"
    end
    
    
  def rank_it ## GOOD
    value = params[:value]
    @phrase = Phrase.find(params[:phrase])
        if params[:definition] != nil
          @definition = @phrase.definitions.find(params[:definition])
        end ## if
    
        if params[:type].downcase == "phrase"
              @phrase.rank += value.to_i
              @phrase.save!
              @element = @phrase
        end ## if
        
        
        
        if params[:type].downcase == "definition"
              @definition.rank += value.to_i
              @definition.save!
              @element = @definition
        end ## if
    
        if params[:type].downcase == "comment"
              @comment = @phrase.comments.find(params[:child])
              @comment.rank += value.to_i
              @comment.save!
              @element = @comment
        end ## if
    
        if params[:type].downcase == "child"
            @child = @definition.children.find(params[:child])
            @child.rank += value.to_i
            @child.save!
            @element = @child
        end #if 
    
    if params[:rank_to]=="one"
       @child_controller_language = params[:child_language]
      render :partial => 'rank_one'
    end ## one
      if params[:rank_to]=="two"
         @child_controller_language = params[:child_language]
        render :partial => 'rank_two'
      end ## two
     if params[:rank_to]=="three"
        @child_controller_language = params[:child_language]
        render :partial => 'rank_three'
    end ## three
  end #def rank_it
    
 def child_language ##GOOD
   @phrase = Phrase.find(params[:phrase])
    @child_controller_language = params[:child_language]
   render :partial => 'definition'
 end
 
 def search_language #GOOD this is for the first select box, changes the language of the main entr
  @phrase = Phrase.find(:first, :conditions=> {:word => params[:phrase], :language => params[:show_language]})||nil
  @language_array = params[:language_array]
#!!!!
 @child_controller_language = params[:child_language]
  @child_lang = params[:child_language]||"English"
  render :partial => 'show'
 end ## def search_language
  
  
 
  def a_z
    ##expire_fragment(%r{phrases/a_z.*}) ## checked out
    
    unless read_fragment({:page => params[:page]||1, :ltr => params[:ltr]||"All"})    
        value =  params[:ltr]
        @value = value
        submit_language = params[:a_z_language]||"English"
        lang = params[:a_z_language]||"English"
        @language = lang
    
      if value == "All" 
          phrases_to_pag = Phrase.find(:all, :order => 'word ASC')
          @phrases = phrases_to_pag.paginate :page => params[:page], :order => 'word ASC', :per_page =>  90
       ## if value == "1"|| value == "2"||value=="3" ||value == "4" ||value == "5" ||value == "6" ||value == "7" ||value == "8" ||value == "9" ||value == "0" || value == "!" ||value == "@" ||value == "#" ||value == "$" ||value == "%" ||value == "^" ||value == "&" ||value == "*" ||value == "(" ||value == ")" ||value == "=" ||value == "+" ||value == "-" ||value == "_"||value == "<" ||value == ">" ||value == "?" ||value == "[" ||value == "}"
       ## endnd
     end
  
      
      if value != "All" 
          temp_phrase = []
           phrase_paginator = Phrase.find(:all, 
             :conditions => [ 'LOWER(word) LIKE ?',
              '%' + value.downcase + '%' ], 
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
   phrases = phrases + Phrase.find(:all, :include => [:definitions => :children], :limit => 5, :offset => ( Phrase.count * rand ).to_i)
   phrases = phrases + Phrase.find(:all, :include => [:definitions => :children], :limit => 5, :offset => ( Phrase.count * rand ).to_i)
   phrases = phrases.sort_by { rand }
   if phrases.empty?
     redirect_to :action => :new
   else
      new_phrases_temp = phrases
       @new_phrases = new_phrases_temp.paginate :page => params[:page], :per_page => 5
      render  :template => "main/random"
   end

 end
 
 def search ## this is what gets called on when you click on a single word
   flash[:notice] = 'This URL was Moved'
   headers["Status"] = "301 Moved Permanently"
   redirect_to :action => :index
 end
 
 def aas
   render :template => 'main/aas_test'
 end
 
 def search_everything
   language = params[:language].to_s
   second_language = params[:second_language].to_s
   #"Simplified","Traditional", "Pinyin"
   query =  params[:query].to_s 
   count = Phrase.count_by_solr(query)
   
   if second_language == "" || second_language == "Simplified"
     @results = Phrase.paginate_all_by_solr("word:#{query} AND language:#{language}",  :page => params[:page], :total_entries => count, :per_page => 5)
   end   
   if second_language == "Traditional"
     @results = Phrase.paginate_all_by_solr("second_word:#{query} AND language:#{language}", :page => params[:page], :total_entries => count, :per_page => 5)
   end
   if second_language == "Pinyin"
     @results = Phrase.paginate_all_by_solr("third_word:#{query} AND language:#{language}", :page => params[:page], :total_entries => count, :per_page => 5)
   end

   
   if second_language == "All"
     @results_1 = Phrase.paginate_all_by_solr("word:#{query} AND language:#{language}", :page => params[:page], :total_entries => count, :per_page => 5)
     @results_2 = Phrase.paginate_all_by_solr("second_word:#{query} AND language:#{language}", :page => params[:page], :total_entries => count, :per_page => 5)
     @results_3 = Phrase.paginate_all_by_solr("third_word:#{query} AND language:#{language}", :page => params[:page], :total_entries => count, :per_page => 5)
     @results = @results_1 + @results_2 + @results_3 
     @results = @results.paginate :page => params[:page], :total_entries => count, :per_page => 5
    end
   
   if @results.empty? == false
       @new_phrases = @results 
   else
      flash[:notice] = "#{query} sounds good to me, but i don't know what it means, <br /> Help everyone out by adding it!"
      
      
      phrase_rescue
   end ## @phrases != nil
   render :template => 'main/show_sphinx'
 end
 
 def phrase_rescue
   @phrase = Phrase.new
   @phrase.language = params[:language].to_s
   @phrase.word =  params[:query].to_s
 end
 
 
 
  def search_everything_1 ## this is what gets called when you use the search box

    @search =  params[:query].to_s
    if @search != nil
      @search = @search[0]
    end
    if params[:search] != nil
      @search = params[:search][:contains]
    end

    @language = params[:language]
    @second_language = params[:second_language]
    
    if @search != nil

        @over_ride = params[:language]
 ##       @phrases = Phrase.search @search, :include => [{:definitions => :children}], :per_page => 5, :conditions => {:language => @language}
      ## , :operator => :and 
      # phrases_word =  Phrase.find_by_solr("word:#{@search}", {:limit => 10})
      # phrases_word = phrases_word.docs
       query =  params[:query].to_s       
       count = Phrase.count_by_solr(query)
       
       
       @results = Phrase.paginate_all_by_solr(query, :page => params[:page], :total_entries => count, :per_page => 5)
       
        @phrases = @results
        
        
       
       if @second_language != nil
         if @second_language.to_s == "Traditional"
            phrases_second_word =  Phrase.find_by_solr("second_word:#{@search}", {:limit => 50})
            phrases_second_word = phrases_second_word.docs
            @phrases = phrases_word + phrases_second_word
         end
         
         if @second_language.to_s == "Pinyin"
            phrases_third_word =  Phrase.find_by_solr("third_word:#{@search}", {:limit => 50})
            phrases_third_word = phrases_third_word.docs
            @phrases = phrases_word + phrases_third_word
         end
       end
       
       new_array = []
       for phrase in @phrases
         if phrase.language == @language
           new_array << phrase
         end
       end

       
       @new_phrases = @results
        @phrases = @results
       # @phrases = new_array
      # @phrases = @phrases.paginate  :per_page => 5, :page => params[:page]
       
      

       if @phrases.empty? == false
           @new_phrases = @phrases 
       else
          flash[:notice] = "#{query} sounds good to me, but i don't know what it means, <br /> Help everyone out by adding it!"
          @phrase = Phrase.new(:word => @search, :language => @language )
       end ## @phrases != nil 
    end ## @search != nil 

    render :template => 'main/show_sphinx'
  end

 
 

 def search_everything_3 ## this is what gets called when you use the search box

    @search =  params[:word]
    if @search != nil
      @search = @search[0]
    end
    if params[:search] != nil
      @search = params[:search][:contains]
    end

    @language = params[:language]

    if @search != nil

        @over_ride = params[:language]
 ##       @phrases = Phrase.search @search, :include => [{:definitions => :children}], :per_page => 5, :conditions => {:language => @language}


      # @phrases =  Phrase.find_by_solr(@search)

     #  @phrases = @phrases.docs
     #   @phrases = @phrases.paginate  :per_page => 5
      @phrases = Phrase.find(:first, :include => [{:definitions => :children}], :conditions=>{:word => @search, :language => @language})||nil
      @phrases = @phrases.to_a
      @phrases = @phrases.paginate  :per_page => 5

       if @phrases.empty? == false
           @new_phrases = @phrases 
       else
         @new_phrases = @phrases 
          flash[:notice] = "#{@search} sounds good to me, but i don't know what it means, <br /> Help everyone out by adding it!"
          @phrase = Phrase.new(:word => @search, :language => @language )
       end ## @phrases != nil 
    end ## @search != nil 

    render :template => 'main/show_sphinx'
  end
  
  
  




 def search_everything_2 ## GOOD
     @search =  params[:search][:contains]
     @over_ride = params[:language]
     @found = Phrase.find(:first, :include => [{:definitions => :children}], :conditions=>{:word => @search, :language => @over_ride})||nil
     if @found != nil 
       if @found.definitions[0] == nil
            flash[:notice] = "#{params[:search][:contains]} sounds good to me, but i don't know what it means, <br /> Help everyone out by defining it!"
       end
       if @found.definitions[0].meaning == "This is a temporary definition, think you could do better, hotshot?"
             flash[:notice] = "#{params[:search][:contains]} sounds good to me, but i don't know what it means, <br /> Help everyone out by defining it!"
        end
       
        redirect_to :action => 'show', :controller => 'phrases', :word => @found.word, :language => @found.language

        

        
        
        
      else
        if @over_ride == "Chinese"||@over_ride == "Korean"||@over_ride == "Japanese"||@over_ride == "Russian"||@over_ride == "Greek"
          redirect_to :action => 'new', :controller => 'phrases', :phrase => params[:search][:contains], :language => params[:language]
          flash[:notice] = "#{params[:search][:contains]} hasn't been added to #{@over_ride} yet, be the first"
          else
            @phrase = Phrase.create(:word => @search, :language => @over_ride, :rank => 1)
            @definition = @phrase.definitions.create(:meaning => "This is a temporary definition, think you could do better, hotshot?", :part_of_speech => "No Clue", 
                                                      :rank => 0)
            @phrase = @phrase.user_log(@phrase.id, logged_in?, current_user)||@phrase
            redirect_to :action => 'show', :controller => 'phrases', :word => @phrase.word, :language => @phrase.language
            flash[:notice] = "#{params[:search][:contains]} sounds good to me, but i don't know what it means, yet <br /> Help everyone out and define it!"
        end # if @over_ride == chinese
     end #if
     
     
     
   end #def search

 def new ## GOOD
    @phrase = Phrase.new
      render :template => 'main/new_slang'
  end #def new

  def edit ## GOOD
    @phrase = Phrase.find(params[:id])
  end #def edit

  def create ## GOOD
        if simple_captcha_valid?||logged_in?
        @found = Phrase.find(:first, :conditions=> {:word => params[:phrase][:word], :language => params[:language] })||nil
        @new_phrase = params[:phrase][:word]
        @language = params[:language] 
        @first_letter = @new_phrase[0,1]
            if (params[:meaning]==nil || params[:part_of_speech]==nil||params[:meaning].empty?||params[:phrase][:word]==nil||params[:phrase][:word].empty?|| @found!=nil) || @first_letter == " "
                  if @found != nil
                      flash[:notice] = 'This word is allready a part of slangasaurus'  
                    else
                     flash[:notice] = 'Hey genius, fill out all required parts <br/> BTW First Letter of word cannot be blank'
                  end # if @found != nil 
                  redirect_to :action => :new, :phrase => params[:phrase][:word], :definition_redirect => params[:meaning],
                                            :part_of_speech_redirect => params[:part_of_speech], :example_redirect => params[:phrase][:example]
            else
                    @phrase = Phrase.create(:rank => 1, :word => @new_phrase.downcase,
                                            :language => @language)
                    @phrase.save!
                    @definition = @phrase.definitions.create(:rank => 1, :meaning => params[:meaning], 
                                              :part_of_speech => params[:part_of_speech],
                                              :example => params[:phrase][:example])
      
                    @phrase = @phrase.user_log(@phrase.id, logged_in?, current_user)||@phrase
                    @definition = @definition.user_log(@definition.id, logged_in?, current_user)||@definition
   
                    respond_to do |format|
                      if @phrase.save!
                        flash[:notice] = 'Phrase was successfully created.'
                        format.html { redirect_to(@phrase) }
                        format.xml  { render :xml => @phrase, :status => :created, :location => @phrase }
                      else
                        format.html { render :action => "new" }
                        format.xml  { render :xml => @phrase.errors, :status => :unprocessable_entity }
                     end #respond_to
                    end #if @phrase.save
            end # if above
      else
            flash[:notice] = 'Captcha Not Correct, You My Good Friend. Clearly Must be a Robot! ^_^'
            redirect_to :action => "new", :phrase => params[:phrase][:word], :definition_redirect => params[:meaning],
                                        :part_of_speech_redirect => params[:part_of_speech], :example_redirect => params[:phrase][:example]
        end ## if captcha is valid
  end #def create

  def auto_complete_for_search_contains ## GOOD
    auto_complete_responder_for_search(params[:search][:contains], params[:first_language], params[:second_language])
  end # def auto_complete_for_message_to
  
  
private
  
  def auto_complete_responder_for_search(value, first_language, second_language)  ## GOOD
    @phrases = Phrase.find(:all, 
      :conditions => [ 'LOWER(word) LIKE ?',
      '%' + value.downcase + '%'], 
      :order => 'word ASC',
      :limit => 10)
    if second_language != nil
    else
      if second_language == "Simplified"
          @phrases = Phrase.find(:all, 
            :conditions => [ 'LOWER(word) LIKE ?',
            '%' + value.downcase + '%'], 
            :order => 'word ASC',
            :limit => 10)
      end  
      if second_language == "Traditional"
          @phrases = Phrase.find(:all, 
            :conditions => [ 'LOWER(second_word) LIKE ?',
            '%' + value.downcase + '%'], 
            :order => 'word ASC',
            :limit => 10)
      end
      if second_language == "Pinyin"
          @phrases = Phrase.find(:all, 
            :conditions => [ 'LOWER(third_word) LIKE ?',
            '%' + value.downcase + '%'], 
            :order => 'word ASC',
            :limit => 10)
      end
    end
      @first_language = first_language
      @second_language = second_language
    render :partial => 'live_search'
  end #def auto_complete_responder_for_contacts(value)  
  
end #class PhrasesController 

  
  
EXPLAIN SELECT "children".* FROM "children" WHERE ("children".definition_id IN (1,354633,647424,673217,700077,371271,329287,342152,342854,345462,348679,357788,366059,379767,382742,385807,389246,391755,391759,391761,391765,391768,391770,391772,391774,391777,391780,391783,391785,391787,391789,391912,391917,391919,391926,391930,391934,391936,391942,569998,581771,596973,602351,611447,630505,679503,679778,679868,680067,688395,689732,690318,704065,712955,634698,489541,351247,469306,489086,489547,519708,519785,577811,577954,635811,635812,635899,635901,656102,665287,705326,680611,436657,3,364506,436661,436663,436665,436668,436670,436672,657993,669754,717477,327095,327097,327100,330262,568879,587117,599605,614112,644621,668747,670324,327086,696499,327089,327093,327092,327096,327099,588266,670323,696498,327101,327102,327091,327106,327103,327105,327107,327104)) ORDER BY rank DESC;




<div id ="delete">
	<% if @element.class.to_s != "Phrase" %>
		<% if @element.class.to_s == "Definition"||@element.class.to_s == "Comment" %>
			<% @type = @element.class %>
		<% else %>
			<% @type = @element.variety %>
		<% end %><!-- if element class == definition -->
		

		<% form_for :phrase, @element, :url => { :action => "battle_it", 
					:phrase => "#{@phrase.id}", :definition => @definition, :type => @type, :child => @element.id,
					:child_language => @child_default } do |f| %>
								<p class="delete_legend">Delete This <%=h @type %> ?</p>
								
									<p>By clicking yes, you will start the silent deathclock (ooooh scary) 
										for this <%=h @type %>. When the clock strikes zero in 30 minutes
										if the <%=h @type %>'s rank is negative it will be fed to the Slangasaur
										and will cease to exist!! If positive it will be spared, do you wish to 
										judge this fine <%=h @type %>??</p>
												
			<% if logged_in? %>	
				<div id = "delete_captcha_position">
				   <img src="/images/dino.gif" height = "90px" width = "90x" /> 
				   <p></p>
				</div><!-- new_dino_position -->
			<% else %>						 
				<div id ="delete_captcha_position">
					<%= show_simple_captcha %>
				</div> <!-- new_captcha_position -->
			<% end %><!-- if logged_in -->										

			<%= f.submit "Start The Countdown?" %>
					<br />
			<span class = "close"><%= link_to_close_redbox("Cancel") %> </span>
					<% end %><!-- form_for -->
					
					
					
			<% else  %><!-- if element.class.to_s != phrase -->
				<% form_for :phrase, @phrase, :url => { :action => "battle_it", 
								:phrase => "#{@phrase.id}", :type => @element.class, :child => @element,
								:child_language => @child_default 
								} do |f| %>
								<p class="delete_legend">Delete This <%=h @element.class %> ?</p>
									<p>By clicking yes, you will start the silent deathclock (ooooh scary) 
										for this <%=h @element.class.to_s.downcase %>. When the clock strikes zero 
										in 30 minutes if the <%=h @element.class.to_s.downcase %>'s  rank is
										negative it will be fed to the Slangasaur and will cease to exist!! 
										If positive it will be spared, do you wish to judge this fine <%=h
											 @element.class.to_s.downcase %>??</p>
		<% if logged_in? %>	
		<p></p>
				<div id = "delete_captcha_position">
				   <img src="/images/dino.gif" height = "90px" width = "90x" /> 
				   <p></p>
				</div><!-- new_dino_position -->
			<% else %>						 
				<div id ="delete_captcha_position">
					<%= show_simple_captcha %>
				</div> <!-- new_captcha_position -->
		<% end %><!-- if logged_in -->
												
														
							  			<input class="submit" type="submit" value = "Start The Countdown!!"">
											<% f.submit "Yes?" %>
										</input>
										<br />
								<span class = "close"><%= link_to_close_redbox("Cancel") %> </span>
						
					<% end %><!-- form_for ->
			
			
<% end %><!-- if @element.class == phrase ->
</div><!-- delete ->



{{db-web}}
{{Infobox Website
| name           = SlangSlang
| <!--logo           = No official logo -->
| screenshot     = [[Image:SlangSlang.png |right|300px|SlangSlang Screenshot.]] 
| caption        = 
| url            = [http://slangslang.com/ www.slangslang.com]
| type           = [[Slang]] [[Dictionary]] [[Thesaurus]]
| language       = [[English language|English]],[[French language|French]],[[Chinese language|chinese]], [[Dutch language| Dutch]], [[German language|German]], [[Greek language|Greek]], [[Italian language|Italian]], [[Japanese language|Japanese]], [[Korean language|Korean]], [[Portuguese language|Portuguese]], [[Russian language|Russian]], [[Spanish language| Spanish]]
| registration   = optional but required for editing
| owner          = Richard Schneeman
| author         = Richard Schneeman
| launch date    = 2008
| current status = active
| revenue        = 
| slogan         = Let Your Language Grow
}}
'''SlangSlang''' is a user submitted [[World Wide Web|Web-based]] [[dictionary]] and [[thesaurus]] of  words, phrases, and names based on user submissions in eleven different languages. Submissions are regulated by all contributors and visitors. Anyone may add to the dictionary, and anyone may rank any entry up or down. When an entry's rank goes below zero, any user can mark the entry for deletion. After thirty minutes if the entry still has a negative rank it is deleted. No registration is required to edit or add. Since all entries are user submitted, the entire database can be downloaded for non-commercial use as text based files<ref name=downloads>[http://www.slangslang.com/phrases/download. : downloads]</ref>
. 

==History==
The dictionary was founded in 2008 by Richard Schneeman, then a senior in [[mechanical engineering]] major at [[Georgia Institute of Technology|Georgia Tech]] (later hired by [[National Instruments]] as an Applications Engineer).<ref name=about>[http://www.slangslang.com/phrases/about. : about]</ref>

==Content==
The definitions on SlangSlang are explanations of every day words, phrases, and names that are commonly used in eleven different languages. Most words have multiple definitions, usage examples, and can include pictures. When enough pictures have been added for a given language, users can test their knowledge of that language by pairing pictures with their associated definitions <ref name=game>[http://www.slangslang.com/phrases/slang_game. : the game]</ref>.

If an entry is missing a definition, synonym, or antonym it shows up under the "orphans" listing on the site where visitors are encouraged to add enough information to make an entry useful.  <ref name=orphans>[http://www.slangslang.com/phrases/orphans. : orphans]</ref>.

[[Racism|Racist]], [[homonegativity|homonegative]] or [[sexism|sexist]] terms are acceptable as long as their definitions only document the use of such [[term of disparagement|slur]]s and are not themselves abusive. While slang often carries a negative connotation, the purpose of SlangSlang is to accelerate understanding of commonly used words and phrases from many languages, and is not meant to solely be a repository for crass material. 



==Quality control==
[[Quality control|Quality]] is regulated [[democracy|democratically]] by all users. Entries are immediately available on the site as soon as they are added. For the first twenty four hours, the "mark for deletion" button is available, and after the first twenty four hours the button will appear if an entry's rank falls below zero. Once marked for deletion, an entry has thirty minutes to attain a positive rank, or it will be deleted from the database. Definitions, synonyms, and antonyms all appear in rank order, so the higher their rank, the sooner they appear on the site. 


==References==
{{reflist}}

==External links==
*[http://www.slangslang.com/ slangslang.com] 


[[Category:Lexicography]]
[[Category:Online dictionaries]]
[[Category:Slang]]
[[Category:Neologisms]]
[[Category:Internet slang]]
[[Category:Web 2.0]]
[[Category:2008 introductions]]
