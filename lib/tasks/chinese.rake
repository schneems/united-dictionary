namespace :chinese do 
  


  desc "adds all chinese files to database"
    task :create => :environment do 
      @user = User.find(:first, :conditions => {:login => 'CEDICT'})
      @user.extra_rank = -89568
      @user.save!
      ## if ENV['value'] == 6.to_s

      
        # File.open('public/languages/chinese/practice.txt').each do |line|
        #  bobby = IO.readlines("public/languages/chinese/practice.txt")
        #  bobby.write ""
         active_dictionary = File.readlines("public/languages/chinese/practice.txt")
         count = 0
      for @element in active_dictionary
             count += 1
             @time = Time.now
             puts @element
             process_chinese
                open('public/languages/chinese/practice.txt', 'w') do |file|
                   file.puts active_dictionary[count,active_dictionary.size]
             end
               
       end
       # end
      ## end 
    end
    
    
    
    def process_chinese   
      chinese = @element.scan(/([^@\s]+)/)
      simplified_character =  chinese[0].to_s
      traditional_character = chinese[1].to_s
      english_array = @element.scan(/\/([^$^\/]+)/)
      english_array = english_array[0,english_array.size-1]
      pinyin = @element.scan(/\[.*\]/).to_s.strip
      pinyin = pinyin[1,pinyin.size-2]      
      english = ''
      new_array = []
      for element in english_array
        english = english + element.to_s.strip + ', '
        new_array << element.to_s.strip
      end
      english_array = new_array
                @phrase =  Phrase.find(:first, :include => [{:definitions => :children }], :conditions => {:word => simplified_character, 
                                       :language => 'Chinese'})||Phrase.create(:word => simplified_character, 
                                         :language => 'Chinese', :second_word => traditional_character, 
                                         :third_word => pinyin, :rank => 1, :user_id => @user.id)
                                       
          if @phrase.save
              @definition =  @definition = @phrase.definitions.find(:first, :conditions => {:meaning => english
                                         })||@phrase.definitions.create(:meaning => english, 
                                         :part_of_speech => 'No Clue', :user_id => @user.id, :rank => 1, :example => nil  )
           end
           
           if english_array != nil && english_array != []
              for element in english_array     
                element = element.to_s
                element = element.strip
                    if @definition.save
                        @child = @definition.children.find(:first, :conditions => {:word => element.downcase, :variety => 'synonym', 
                                           :language =>'English'} )||@definition.children.create(:word => element.downcase,
                                                                   :rank => 1, :variety => 'synonym', :language =>'English' )
                        if @child.save
                            @recently_created = @child 
                            @variety = "synonym"
                            chinese_slang_rabbit      
                        end
                    end  
                end ## for element
          end ## if english_element
    end ##def
    
    
desc "finds all entries added by cedict and deletes them"
    task :cedict_destroy => :environment do 
      @user = User.find(:first, :conditions => {:login => 'CEDICT'})
      @phrases = Phrase.find(:all, :include => [{:definitions => :children }], :conditions => {:user_id => @user.id })
      puts @phrases.size
      for phrase in @phrases
        phrase.destroy
      end
      @user = User.find(:first, :conditions => {:login => 'gtg215x'})||User.create(:login => 'gtg215x',
                        :email => 'Wordnetschneeman@gmail.com', :password => 'Dick999', :password_confirmation => 'Dick999' )                  
      @phrases = Phrase.find(:all, :include => [{:definitions => :children }], :conditions => {:user_id => @user.id })
      puts @phrases.size
      for phrase in @phrases
        phrase.destroy
      end      
      @definitions = Definition.find(:all, :include => [:children], :conditions => {:user_id => @user.id})
      for definition in @definitions
        definition.destroy
      end
      
    end





  desc "destroys all chinese files to database"
    task :destroy => :environment do 
      File.open('public/languages/chinese/cedict_ts.u8').each do |line|
          @element = line
              chinese = @element.scan(/([^@\s]+)/)
              simplified_character =  chinese[0]
              english_array = @element.scan(/\/([\w . , ]+)/)
              @phrase = Phrase.find(:first, :include => [:definitions], :conditions => {:word => simplified_character, :language => 'Chinese'})
              if @phrase != nil 
                @phrase.destroy
              end
                for element in english_array
                    @child = Phrase.find(:first, :include => [:definitions], :conditions =>  {:word => element.to_s, :language =>'English'} )
                    if @child != nil 
                        @child.destroy
                    end
                end
        end ## for element
    end #rake task
    
    
    def chinese_slang_rabbit
      @spider_user = @user
       @def_id = @recently_created.definition_id 
       @definition = Definition.find(@def_id) ## definition of parent
       @language = @recently_created.language ## language of child just added
      ## @phrase_id = @definition.phrase_id
      ## @phrase = Phrase.find(@phrase_id)
       @recently_created_phrase = Phrase.find(:first, 
                  :conditions=>{:word => @recently_created.word,
                  :language => @recently_created.language})||Phrase.create(:rank => 1,
                  :word => @recently_created.word , :second_word => @recently_created.second_word, :third_word => @recently_created.third_word, 
                  :user_id =>  @spider_user.id, 
                  :language => @recently_created.language) ## phrase created by new child
        if @variety.to_s.downcase == "antonym" || @recently_created_phrase.created_at-Time.now > 30240
          ## do nothing
        else
           @recently_created_definition = @recently_created_phrase.definitions.find(:first,:conditions=> 
                                     {:meaning => @definition.meaning})||@recently_created_phrase.definitions.create(:rank => 1, :meaning => 
                                     @definition.meaning, :part_of_speech => @definition.part_of_speech, :user_id => @spider_user.id,
                                     :example => @definition.example)
         ## @recently_created_definition = @definition.user_log(@recently_created_definition.id, true, @user.id)||@recently_created_definition
           @recently_created_child = @recently_created_definition.children.find(:first, :conditions => {:word => @phrase.word,
                                       :rank => 1, :language => @phrase.language })||@recently_created_definition.children.create(
                                       :word => @phrase.word, :second_word => @phrase.second_word, :third_word => @phrase.third_word, 
                                       :rank => 1, :language => @phrase.language, :variety => @variety, :user_id =>  @spider_user.id )

         # This part takes existing phrases, and adds new words while making them phrases if they are not allready
                 for child in @definition.children
                    ## populates recently created Phrase with current synonyms
                     @child = child
                     @authentication_is = @recently_created_phrase.authenticate(@recently_created_phrase, @recently_created_definition, @child.word.to_s, @child.language.to_s )
                     if @authentication_is == true
                        @save_me =  @recently_created_definition.children.create(:rank => 1, :variety => @child.variety, :word => @child.word, 
                                                                           :second_word => @child.second_word,  :third_word => @child.third_word,  
                                                                           :language => @child.language, :user_id => @spider_user.id)
                     end #if
                   ## this section finds the phrases that should allready exist and populates them with the new word
                   ## more specifically this part finds the exising phrase and definition, and just incase it can't, creates them   
                     @existing_phrase = Phrase.find(:first, :conditions => {:word => @child.word, :language => @child.language})||
                                            Phrase.create( :rank => 1,  :word => @child.word,:second_word => @child.second_word, 
                                             :third_word => @child.third_word,  :language => @child.language, :user_id =>  @spider_user.id)
                     @existing_definition = @existing_phrase.definitions.find(:first, :conditions => {:meaning => @definition.meaning})||
                                                @existing_phrase.definitions.create( :rank => 1, :meaning => @definition.meaning, :user_id =>  @spider_user.id, 
                                               :part_of_speech => @definition.part_of_speech, 
                                               :example => @definition.example)
                  ## This is the meat and potatoes of the whole shebang
                     @authentication_is = @existing_phrase.authenticate(@existing_phrase, @existing_definition, @recently_created.word,  @recently_created.language )
                        if @authentication_is == true
                          @save_me =  @existing_definition.children.create( :rank => 1, :variety => @recently_created.variety, :word => @recently_created.word,
                                                                             :second_word => @recently_created.second_word,  :third_word => @recently_created.third_word,  
                                                                             :language => @recently_created.language, :user_id =>  @spider_user.id )
                        end # if authentication
                 end #for
             end # if equals antonym

      end ##def slang_rabbit
    
    
end ##namespace