
namespace :spider do 
  desc "crawls a site"
      task :destroy => :environment do
        @spider_user = User.find(:first, :conditions => {:login => 'WordNet'})||User.create(:login => 'WordNet',
                          :email => 'Wordnetschneeman@gmail.com', :password => 'Dick999', :password_confirmation => 'Dick999' )
        @phrases = Phrase.find(:all, :conditions => {:user_id => @spider_user.id})
        for phrase in @phrases
          phrase.destroy
        end
      
  end
      
  
  
  
  desc "crawls a site"
      task :crawl => :environment do
        @spider_user = User.find(:first, :conditions => {:login => 'WordNet'})||User.create(:login => 'WordNet',
                          :email => 'Wordnetschneeman@gmail.com', :password => 'Dick999', :password_confirmation => 'Dick999' )
        @spider_user.save!

        
        @begin_time =  Time.now
        require 'net/http'
      File.open('public/languages/english/word_list.txt').each do |line|
        request_value = '/perl/webwn?s=' + line.strip
        response = Net::HTTP.get_response('wordnet.princeton.edu', request_value)
        english_array = response.body.scan(/(\<li\>.*\<\/li\>)/)  ## (<li>.*</li>)    takes all values between list items in an array
           if english_array != nil
               for list_item in english_array
                ## list_item.class ## is an array
                child_array =  list_item[0].scan(/[^>]+\<\/a\>/) ## [^>]+</a> pulls out all things that end in "asdfasdfsadfasdf</a>" need to remove </a>
                if child_array != nil && child_array.size > 2
                  ## child_array[0] is always S: or L:, need to ignore
                  ## child_array[1] this is the part of speech
                  temp_pos =  child_array[1].strip
                  if temp_pos == "(n) </a>"
                    part_of_speech = "Noun"
                  end  ## if
                  if temp_pos == "(v) </a>"
                    part_of_speech = "Verb"
                  end  ## if
                  if temp_pos == "(adv) </a>"
                    part_of_speech = "Adverb"
                  end  ## if
                  if temp_pos == "(adj) </a>"
                    part_of_speech = "Adjective"
                  end  ## if
                  if part_of_speech == nil
                    part_of_speech = temp_pos[1,1].upcase
                  end ## if
                  english = ''
                  new_array = []
                  for element in  child_array[2,child_array.size]
                     element = element[0,element.size-4].strip.downcase
                     english = english + element.to_s + ', '
                     new_array << element
                  end ## for element in child_array
                  english_array = new_array
                 ## english asdf, asdf, asdf, asdfasd, asdf write this to file
                 example =  list_item[0].scan(/[^>]+\<\/i\>/) ## [^>]+</i> pulls out all things that end in "asdfadsfasd</i>" need to remove </i>, may match nothing
                 example =  example[0]
                 if example != nil
                   example =  example[0, example.size-4]
                 else 
                   example = ""
                 end ## if example
                 
                 definition =  list_item[0].scan(/\([^>]+\)/) ## \([^>]+\)    pulls out (n)"evaluate and covert", and (definition) take off parentheses
                 if definition[1] != nil
                   definition =  definition[1].strip
                   definition = definition[1,definition.size-2]
                 else
                   definition = "No Definition"
                 end
                    open('public/languages/english/write.txt', 'a') do |file|
                        file.puts "Word: " + line.strip + " (" + part_of_speech + ")  " + "Definition: " + definition + "- "  + example + " Synonyms: "  + english + " "
                    end
##===============================
              if @phrase != nil
                if @phrase.word != line
                  @phrase =  Phrase.find(:first, :include => [:definitions], :conditions => {:word => line.strip.downcase, :language => 'English'} )||Phrase.create(:word => line.strip.downcase, :language => 'English', :rank => 1, :user_id => @spider_user.id)
                end ## if
              else
                 @phrase =  Phrase.find(:first, :include => [:definitions], :conditions => {:word => line.strip.downcase, :language => 'English'} )||Phrase.create(:word => line.strip.downcase, :language => 'English', :rank => 1, :user_id => @spider_user.id)
              end ## if
              
              if @phrase.save
                  @definition = @phrase.definitions.find(:first, :conditions => { :meaning => definition, 
                                                  :example => example})||@phrase.definitions.create(:meaning => definition, 
                                                  :part_of_speech => part_of_speech, :user_id => @spider_user.id, :rank => 1,
                                                  :example => example )
               end ## @phrase.save
 
               if english_array != nil && english_array != []
                  for element in english_array     
                    element = element.to_s
                    element = element.strip
                        if @definition.save
                                @child =  @definition.children.find(:first, :conditions => {:word => element.downcase,:variety => 'synonym', 
                                                                :language =>'English'} )||@definition.children.create(:word => element.downcase, 
                                                                :rank => 1, :variety => 'synonym', :language =>'English' )
              
                            if @child.save
                                @recently_created = @child 
                                @variety = "synonym"
                                slang_rabbit      
                            end ## if child.save
                          end ## if @definition.save
                        end  ## if english_array 
                    end ## for element
 ##===============================     
                end ## if child_array 
                
                
                ## \([^>]+\)        pulls out (n)"evaluate and covert", and (definition) take off parentheses
                ## ([^<>^\/a\/i]+)
             end #for list_item in english_array
          end ## english_array != nil 

        ##  open('public/languages/english/read.txt', 'a') do |file|
        ##    file << response.body
        ##  end
        
        
      end ## file.open('public') 

      
      puts Time.now - @begin_time
  end ## task   
  
    
    def slang_rabbit
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
  
  
  
end ## namespace