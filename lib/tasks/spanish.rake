namespace :spanish do 
  
  desc "finds all entries added by freedict and deletes them"
      task :freedict_destroy => :environment do 
        @user = User.find(:first, :conditions => {:login => 'freedict'})
        @phrases = Phrase.find(:all, :include => [{:definitions => :children}], :conditions => {:user_id => @user })
        for phrase in @phrases
          phrase.destroy
        end
      end
  
  
      desc "adds dem perty spanish words"
    task :create => :environment do 
      @user = User.find(:first, :conditions => {:login => 'freedict'})||User.create(:login => 'freedict',
                        :email => 'Wfreedictschneeman@gmail.com', :password => 'engineer', :password_confirmation => 'engineer' )
      @user.extra_rank = -89568
      @user.save!
      
       active_dictionary = File.readlines("public/languages/spanish/practice.txt")
       count = 0
       
       for @element in active_dictionary
           count += 1
           @time = Time.now
           puts @element
           process_spanish
         open('public/languages/spanish/practice.txt', 'w') do |file|
            file.puts active_dictionary[count,active_dictionary.size]
        end
          puts Time.now - @time
        
      end ## each line do

    end ##task 
    
    
    
    task :add_comma  => :environment do 
       active_dictionary = File.readlines("public/languages/spanish/spanish-english-fredict.txt")
       count = 0     
       for @element in active_dictionary
           count += 1
           @time = Time.now
           foo  = @element[0,@element.size-1] << ","
           puts foo
           open('public/languages/spanish/practice.txt', 'a') do |file|
               file.puts foo
           end  
      end ## each line do
    end #task 
  
    
    
    def process_spanish
          spanish = (/.*\t/.match(@element)).to_s
          spanish = spanish.strip
          english = @element[spanish.size, @element.size]
          english_array = english.scan(/([\w \- . ? ]+),/)
          english_size = english.size
          end_of_english = english_size
          english = ''
          new_english_array = []
          for element in english_array
            element = element.to_s.strip
            new_english_array << element
            english = english + element + ', '
          end
          english_array = new_english_array
           @phrase = Phrase.find(:first, :conditions => {:word => spanish, :language => 'Spanish'} )||Phrase.create(:word => spanish, :language => 'Spanish', :rank => 1, :user_id => @user.id)
          if @phrase != nil
              @definition =  @phrase.definitions.find(:first, :conditions => { :meaning => english, 
                                          :part_of_speech => 'No Clue'})||@phrase.definitions.create(:meaning => english, 
                                              :part_of_speech => 'No Clue', :user_id => @user.id, :rank => 1, :example => nil  )
           end

           if english_array != nil && english_array != []
              for element in english_array     
                element = element.to_s
                element = element.strip
                    if @definition != nil
                            @child =  @child = @definition.children.find(:first, :conditions => {:word => element.downcase, :variety => 'synonym', 
                                                                :language =>'English'} )||@definition.children.create(:word => element.downcase, 
                                                :rank => 1, :variety => 'synonym', :language =>'English' )
                      
                        if @child != nil
                          
                            @recently_created = @child 
                            @variety = "synonym"  
                            @def_id = @recently_created.definition_id 
                            slang_rabbit_spanish      
                        end ## if @child.save
                    end  
                end ## for element
          end ## if english_element
    end
    
    
    
      def slang_rabbit_spanish
         @def_id = @recently_created.definition_id 
         @definition = Definition.find(@def_id) ## definition of parent
         @language = @recently_created.language ## language of child just added
        ## @phrase_id = @definition.phrase_id
        ## @phrase = Phrase.find(@phrase_id)
         @recently_created_phrase = Phrase.find(:first, :include => [{:definitions => :children }],
                    :conditions=>{:word => @recently_created.word,
                    :language => @recently_created.language})||Phrase.create(:rank => 1,
                         :word => @recently_created.word , :second_word => @recently_created.second_word, :third_word => @recently_created.third_word, 
                         :language => @recently_created.language, :user_id => @user.id) ## phrase created by new child


          if @variety.to_s.downcase == "antonym" || @recently_created_phrase.created_at-Time.now > 30240
            ## do nothing
          else
             @recently_created_definition = @recently_created_phrase.definitions.find(:first,  :include => [:children ],
                                        :conditions=> 
                                       {:meaning => @definition.meaning})|| @recently_created_phrase.definitions.create(:rank => 1, :meaning => 
                                                                          @definition.meaning, :part_of_speech => @definition.part_of_speech,
                                                                          :example => @definition.example, :user_id => @user.id)



           ## @recently_created_definition = @definition.user_log(@recently_created_definition.id, true, @user.id)||@recently_created_definition
             @recently_created_child = @recently_created_definition.children.find(:first, :conditions => {:word => @phrase.word,
                                         :rank => 1, :language => @phrase.language })||@recently_created_definition.children.create(
                                    :word => @phrase.word, :second_word => @phrase.second_word, :third_word => @phrase.third_word, 
                                    :rank => 1, :language => @phrase.language, :variety => @variety,  :user_id => @user.id )




           # This part takes existing phrases, and adds new words while making them phrases if they are not allready
                   for child in @definition.children
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
                       @existing_phrase = Phrase.find(:first, :include => [{:definitions => :children}], 
                                          :conditions => {:word => @child.word, :language => @child.language})||Phrase.create( :rank => 1,  :word => @child.word,:second_word => @child.second_word, 
                                               :third_word => @child.third_word,  :language => @child.language, :user_id => @user.id )
                       @existing_definition = @existing_phrase.definitions.find(:first, 
                                                :conditions => {:meaning => @definition.meaning})
                       @existing_phrase.definitions.create( :rank => 1, 
                                                :meaning => @definition.meaning, 
                                                :part_of_speech => @definition.part_of_speech, 
                                                :user_id => @user.id )       
                    ## This is the meat and potatoes of the whole shebang
                       @authentication_is = @existing_phrase.authenticate(@existing_phrase, @existing_definition, @recently_created.word,  @recently_created.language )
                          if @authentication_is == true
                            @save_me =  @existing_definition.children.create( :rank => 1, :variety => @recently_created.variety, :word => @recently_created.word,
                                                                               :second_word => @recently_created.second_word,  :third_word => @recently_created.third_word,  
                                                                               :language => @recently_created.language )
                          end # if authentication
                   end #for
               end # if equals antonym
        end ##def slang_rabbit
 
    
    
end ##namespace