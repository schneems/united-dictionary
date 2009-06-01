class Child < ActiveRecord::Base
    belongs_to :user
    belongs_to :definition
    validates_uniqueness_of :word, :case_sensitive => true, :scope => [:definition_id, :language], :message => "This Entry is Already a part of this slang"
    validates_presence_of :word, :message => "Entry Cannot Be Blank"
   # validates_not_spam :word, :second_word, :third_word
    
    before_save :format_entries


    def format_entries
      self.word = word.downcase.strip.squeeze(" ") unless self.word == nil 
      self.second_word = second_word.downcase.strip.squeeze(" ") unless self.second_word == nil 
      self.third_word = third_word.downcase.strip.squeeze(" ") unless self.third_word == nil 
      self.rank = 1 if self.rank == nil
    end
    
    def create_phrase_for_child 
      ## if a child is created as an antonym we want to create a phrase for it
      ## creates new phrase to match child
      new_phrase = Phrase.find(:first, :conditions => {:word => word,
                                :language => language})||Phrase.create(:word => word, 
                                :language => language)
                    
      ## if a child is created as an antonym we want to either not create a definition for it
      ## or specify that it is the oposite of the definition
      if variety.downcase != "antonym" && new_phrase.save
        ## creates a definition for the new phrase
          new_def = new_phrase.definitions.find(:first, :conditions => 
                            {:meaning => definition.meaning})||new_phrase.definitions.create(:meaning => definition.meaning,
                             :example => definition.example, :part_of_speech => definition.part_of_speech, :rank => 1)
          ## populates new definition with children from old definition                   
            for child in definition.children
              new_child = new_def.children.find(:first, :conditions => {:word => child.word,
                                :language => child.language})||new_def.children.create(:word => child.word, 
                                :second_word => child.second_word, 
                                :third_word => child.third_word, 
                                :language => child.language,
                                :variety => child.variety, :rank => 1) if (child.word != word or child.language != language) || child.word != new_phrase.word
            end
          ## adds the 
              new_child = new_def.children.find(:first, :conditions => {:word => definition.phrase.word,
                              :language => definition.phrase.language})||new_def.children.create(:word => definition.phrase.word, 
                              :second_word => definition.phrase.second_word, :third_word => definition.phrase.third_word, 
                              :language => definition.phrase.language,
                              :variety => "synonym", :rank => 1) if self.word != definition.phrase.word
          #definition = phrase.definitions.find(:first, :conditions => {:meaning => })
      end

      
    end
    
    
    
    def populate_all_child_phrases 
      for child in self.definition.children
        child.create_phrase_for_child
      end
    end
    ## function needs to find all children of a Phrase >> Definition >> Children
    ## for child in children
    ## find @exising_phrase = phrase(:word => child.word, :language => child.language) || create
    ## find @exising_definition = @existing_phrase.definitions(:meaning => child.definition.meaning)|| create
    ## @existing_definition.children.find || children.create 
    
    
      def user_log(id, login, user)
        if login   
          @children = Child.find(id)
          if @children.user_id == nil
            @children.update_attributes(:user_id => user.id)
          end ## if @children.user_id
        end ## if login
        @children
      end ## def user_log

    
    
end
