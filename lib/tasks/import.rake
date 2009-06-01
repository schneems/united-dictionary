namespace :import do     
  
 task :kill_french => :environment do 
    @Phrase = Phrase.find(:all, :include => [:definitions => :children], :conditions => {:language => "French"})
    puts @Phrase.size
    
    @children = Child.find(:all, :conditions => {:language => "French"})
    puts @children.size
    
    for child in @children
      child.destroy
    end
    
    for phrase in @Phrase
      phrase.destroy
    end
  end
    
    
    def process_lang 
      ## so everything before tab is actually dutch, lulz
      scan_array = @element.scan(/([\w \- \. \( \) \? ]+)/) ## this picks up, all words, first is dutch, last is part of speech, all inbetween are english
      pick_the_first = @element.scan(/([\w \- \. \( \) \? \;]+)/)     ## ([\w \- \. \( \) \? ;]+) the first entry is all the dutch entries
      foreign_string = pick_the_first[0].to_s

      
      foreign_array = foreign_string.scan(/([\w \- \. \( \) \? ]+)/)
      new_array = []
      
      
      for element in foreign_array
        element = element[0]
        new_array << element.strip
      end  
      foreign_array = new_array
      
      foreign_word  =  foreign_array[0]
      foreign_array = foreign_array[1,foreign_array.size]

      part_of_speech = "No Clue" #scan_array[scan_array.size-1].to_s.strip
      english_array = scan_array[foreign_array.size+1,scan_array.size-2]
      english = ""
      new_array = []
      for element in english_array
        temp = element.to_s.strip
        english = english + temp + ', '
        new_array << temp
      end
      english_array = new_array
          @phrase =  Phrase.find(:first, :include => [{:definitions => :children }], :conditions => {:word => foreign_word, 
                                      :language => @import_language})||Phrase.create(:word => foreign_word, 
                                        :language => @import_language, 
                                        :rank => 1, :user_id => nil)
          if @phrase.save
              @definition =  @phrase.definitions.find(:first, :conditions => {:meaning => english
                                         })||@phrase.definitions.create(:meaning => english, 
                                         :part_of_speech => part_of_speech, :user_id => nil, :rank => 1, :example => nil  )
           end
           
           if english_array != nil && english_array != []
              for element in english_array     
                    if @definition.save
                        @child = @definition.children.find(:first, :conditions => {:word => element.downcase, :variety => 'synonym', 
                                           :language =>'English'} )||@definition.children.create(:word => element.downcase,
                                                                   :rank => 1, :variety => 'synonym', :language =>'English' )
                        
                        if @child.save
                            @recently_created = @child 
                            @variety = "synonym"
                            import_slang_rabbit      
                        end     
                    end  
                end ## for element
          end ## if english_element
           if foreign_array.size != 0
              for element in foreign_array
                 if @definition.save
                      @child = @definition.children.find(:first, :conditions => {:word => element.downcase, :variety => 'synonym', 
                                         :language => @import_language} )||@definition.children.create(:word => element.downcase,
                                                                 :rank => 1, :variety => 'synonym', :language => @import_language )
                      if @child.save
                          @recently_created = @child 
                          @variety = "synonym"
                          import_slang_rabbit      
                      end ## if @child.save
                  end ## if @definition.save
              end ## for element in foreign_array
            end ## if element in foreign_array
    end ##def
    
  
    def import_slang_rabbit
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
                  :user_id =>  nil, 
                  :language => @recently_created.language) ## phrase created by new child
                  
        if @variety.to_s.downcase == "antonym" || @recently_created_phrase.save == false
          ## do nothing
        else
           @recently_created_definition = @recently_created_phrase.definitions.find(:first,:conditions=> 
                                     {:meaning => @definition.meaning})||@recently_created_phrase.definitions.create(:rank => 1, :meaning => 
                                     @definition.meaning, :part_of_speech => @definition.part_of_speech, :user_id => nil,
                                     :example => @definition.example)
         ## @recently_created_definition = @definition.user_log(@recently_created_definition.id, true, @user.id)||@recently_created_definition
           @recently_created_child = @recently_created_definition.children.find(:first, :conditions => {:word => @phrase.word,
                                       :rank => 1, :language => @phrase.language })||@recently_created_definition.children.create(
                                       :word => @phrase.word, :second_word => @phrase.second_word, :third_word => @phrase.third_word, 
                                       :rank => 1, :language => @phrase.language, :variety => @variety, :user_id =>  nil )

         # This part takes existing phrases, and adds new words while making them phrases if they are not allready
                 for child in @definition.children
                    ## populates recently created Phrase with current synonyms
                     @child = child
                     @authentication_is = @recently_created_phrase.authenticate(@recently_created_phrase, @recently_created_definition, @child.word.to_s, @child.language.to_s )
                     if @authentication_is == true
                        @save_me =  @recently_created_definition.children.create(:rank => 1, :variety => @child.variety, :word => @child.word, 
                                                                           :second_word => @child.second_word,  :third_word => @child.third_word,  
                                                                           :language => @child.language, :user_id => nil)
                     end #if
                   ## this section finds the phrases that should allready exist and populates them with the new word
                   ## more specifically this part finds the exising phrase and definition, and just incase it can't, creates them   
                     @existing_phrase = Phrase.find(:first, :conditions => {:word => @child.word, :language => @child.language})||
                                            Phrase.create( :rank => 1,  :word => @child.word,:second_word => @child.second_word, 
                                             :third_word => @child.third_word,  :language => @child.language, :user_id =>  nil)
                 if @existing_phrase.save != false                          
                     @existing_definition = @existing_phrase.definitions.find(:first, :conditions => {:meaning => @definition.meaning})||
                                                @existing_phrase.definitions.create( :rank => 1, :meaning => @definition.meaning, :user_id =>  nil, 
                                               :part_of_speech => @definition.part_of_speech, 
                                               :example => @definition.example)
                  end ## if
                  ## This is the meat and potatoes of the whole shebang
                     @authentication_is = @existing_phrase.authenticate(@existing_phrase, @existing_definition, @recently_created.word,  @recently_created.language )
                        if @authentication_is == true
                          @save_me =  @existing_definition.children.create( :rank => 1, :variety => @recently_created.variety, :word => @recently_created.word,
                                                                             :second_word => @recently_created.second_word,  :third_word => @recently_created.third_word,  
                                                                             :language => @recently_created.language, :user_id =>  nil )
                        end # if authentication
                 end #for
             end # if equals antonym

      end ##def slang_rabbit
    
    


desc "adds all dutch files to database"
  task :dutch => :environment do 
       @import_language = "Dutch"
       active_dictionary = File.readlines("public/languages/dutch/practice.txt")
       count = 0
       write_count = 0
    for @element in active_dictionary
           count += 1
           write_count += 1
       @time = Time.now
       puts @element
     process_lang
    if write_count > 10
      write_count = 0
       open('public/languages/dutch/practice.txt', 'w') do |file|
          file.puts active_dictionary[count,active_dictionary.size]
      end ## open
    end ## if write_count > 10
     puts Time.now - @time
   
     end ## for elemenet in active_dictionary
     # end
    ## end 
  end ## end task
  
  desc "adds all French files to database"
    task :french => :environment do 
         @import_language = "French"
         active_dictionary = File.readlines("public/languages/french/practice.txt")
         count = 0
         write_count = 0
      for @element in active_dictionary
             count += 1
             write_count += 1
         @time = Time.now
         puts @element
       process_lang
      if write_count > 10
        write_count = 0
         open('public/languages/French/practice.txt', 'w') do |file|
            file.puts active_dictionary[count,active_dictionary.size]
        end
      end
        puts Time.now - @time
       end
       # end
      ## end 
    end


    desc "adds all German files to database"
      task :german => :environment do 
           @import_language = "German"
           active_dictionary = File.readlines("public/languages/German/practice.txt")
           count = 0
           write_count = 0
        for @element in active_dictionary
               count += 1
               write_count += 1
           @time = Time.now
           puts @element
         process_lang
        if write_count > 10
          write_count = 0
           open('public/languages/German/practice.txt', 'w') do |file|
              file.puts active_dictionary[count,active_dictionary.size]
          end
        end
          puts Time.now - @time

         end
         # end
        ## end 
      end

        desc "adds all Greek files to database"
          task :greek => :environment do 
               @import_language = "Greek"
               active_dictionary = File.readlines("public/languages/Greek/practice.txt")
               count = 0
               write_count = 0
            for @element in active_dictionary
                   count += 1
                   write_count += 1
               @time = Time.now
               puts @element
             process_lang
            if write_count > 10
              write_count = 0
               open('public/languages/Greek/practice.txt', 'w') do |file|
                  file.puts active_dictionary[count,active_dictionary.size]
              end
            end
              puts Time.now - @time

             end
             # end
            ## end 
          end

            desc "adds all Italian files to database"
              task :italian => :environment do 
                   @import_language = "Italian"
                   active_dictionary = File.readlines("public/languages/Italian/practice.txt")
                   count = 0
                   write_count = 0
                for @element in active_dictionary
                       count += 1
                       write_count += 1
                   @time = Time.now
                   puts @element
                 process_lang
                if write_count > 10
                  write_count = 0
                   open('public/languages/Italian/practice.txt', 'w') do |file|
                      file.puts active_dictionary[count,active_dictionary.size]
                  end
                end
                  puts Time.now - @time

                 end
                 # end
                ## end 
              end

                desc "adds all Japanese files to database"
                  task :Japanese => :environment do 
                       @import_language = "Japanese"
                       active_dictionary = File.readlines("public/languages/Japanese/practice.txt")
                       count = 0
                       write_count = 0
                    for @element in active_dictionary
                           count += 1
                           write_count += 1
                       @time = Time.now
                     process_lang
                    if write_count > 10
                      write_count = 0
                       open('public/languages/Japanese/practice.txt', 'w') do |file|
                          file.puts active_dictionary[count,active_dictionary.size]
                      end
                    end
                      puts Time.now - @time

                     end
                     # end
                    ## end 
                  end

                           desc "adds all Korean files to database"
                              task :Korean => :environment do 
                                   @import_language = "Korean"
                                   active_dictionary = File.readlines("public/languages/Korean/practice.txt")
                                   count = 0
                                   write_count = 0
                                for @element in active_dictionary
                                       count += 1
                                       write_count += 1
                                   @time = Time.now
                                 process_lang
                                if write_count > 10
                                  write_count = 0
                                   open('public/languages/Korean/practice.txt', 'w') do |file|
                                      file.puts active_dictionary[count,active_dictionary.size]
                                  end
                                end
                                  puts Time.now - @time

                                 end
                                 # end
                                ## end 
                              end


   desc "adds all Portugese files to database"
                  task :portuguese => :environment do 
                       @import_language = "Portuguese"
                       active_dictionary = File.readlines("public/languages/portuguese/practice.txt")
                       count = 0
                       write_count = 0
                    for @element in active_dictionary
                           count += 1
                           write_count += 1
                           
                       @time = Time.now
                       puts @element
                     process_lang
                    if write_count > 10
                      write_count = 0
                       open('public/languages/portuguese/practice.txt', 'w') do |file|
                          file.puts active_dictionary[count,active_dictionary.size]
                      end
                    end
                      puts Time.now - @time

                     end
                     # end
                    ## end 
                  end


                  desc "adds all russian files to database"
                                 task :russian => :environment do 
                                      @import_language = "Russian"
                                      active_dictionary = File.readlines("public/languages/russian/practice.txt")
                                      count = 0
                                      write_count = 0
                                   for @element in active_dictionary
                                          count += 1
                                          write_count += 1

                                      @time = Time.now
                                      puts @element
                                    process_lang
                                   if write_count > 10
                                     write_count = 0
                                      open('public/languages/russian/practice.txt', 'w') do |file|
                                         file.puts active_dictionary[count,active_dictionary.size]
                                     end
                                   end
                                     puts Time.now - @time

                                    end
                                    # end
                                   ## end 
                                 end







                end ##namespace
