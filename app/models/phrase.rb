class Phrase < ActiveRecord::Base  
  belongs_to :user
  has_many :mugshots, :order => 'rank DESC', :dependent => :destroy
  has_many :comments, :order => 'rank DESC', :dependent => :destroy
  has_many :relateds, :order => 'rank DESC', :dependent => :destroy
  has_many :alternates, :order => 'rank DESC', :dependent => :destroy
  has_many :definitions, :order => 'rank DESC', :dependent => :destroy
  validates_presence_of :word, :message => "or Entry Cannot Be Blank"
  validates_presence_of :language
  
  validates_not_spam :word, :second_word, :third_word  
  validates_uniqueness_of :word, :scope => :language, :message => " or Entry and language pair is already in the database"
  
  # acts_as_solr :fields => [ :word, :second_word, :third_word, :language ], :facets => [:languaqge] 
  #require 'solr_pagination'
  
  before_save :format_entries
      
 # def self.validates_ssn(*attr_names) 
 #   attr_names.each do |attr_name| 
 #     validates_format_of attr_name, 
 #       :with => /^[\d]{3}-[\d]{2}-[\d]{4}$/, 
 #       :message => "must be of format ###-##-####" 
 #   end 
 # end
      
  
  def format_entries
    self.word = word.downcase.strip.squeeze(" ") unless self.word == nil 
    self.second_word = second_word.downcase.strip.squeeze(" ") unless self.second_word == nil 
    self.third_word = third_word.downcase.strip.squeeze(" ") unless self.third_word == nil 
    self.rank = 1 if self.rank == nil
  end
  
  
  
  after_update :save_definitions


  def new_definition_attributes=(definition_attributes)
    definition_attributes.each do |attributes|
      definitions.build(attributes)
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
   
   

  def self.find_with_children(phrase_id)
    Phrase.find(:first, :include => [:definitions => :children], :conditions => {:id => phrase_id })
  end

  def self.find_top(page)
    @definitions = []
    @definitions = Definition.find_top_rank
    @phrases = []
    @phrases = @definitions.collect {|definition| definition.phrase}
    @phrases.uniq!
      if @phrases != nil
          @phrases = @phrases.paginate(:page => page, :order => 'word ASC', :per_page => 5)
      end ## if @phrase !=nil
    @phrases
  end




     def self.get_paths(limit, offset, element_count)
       path_ar = []            
       ## this code checks to see if we're in our last iteration and adjusts accordingly
       if (limit + offset) >= element_count
         limit = element_count - offset
         start = element_count 
       end
       self.find(:all, :limit => limit, :offset => offset).each do |model|
         path_ar << {:url => "/slang/#{model.language}/#{model.word}", :last_mod => model.updated_at.strftime('%Y-%m-%d')}
       end
       path_ar
     end
     
     

  def user_log(phrase_id, login, user)
    if login
      @phrase = Phrase.find(phrase_id)
      if @phrase.user_id == nil
        @phrase.update_attributes(:user_id => user.id)
      end
    end
    @phrase
  end
     
     
     
   def alphasearch(value)  ## put back into private
    @alphasearch = Phrase.find(:all, 
      :conditions => [ 'LOWER(word) LIKE ?',
      '%' + value.downcase + '%' ], 
      :order => 'word ASC')
      @alphasearch
  end #def auto_complete_responder_for_contacts(value)  
  
    
    
  def authenticate(phrase, definition,word,language)
      @authentication_is = true
      if phrase == nil || definition == nil || word == nil || language == nil
        @authentication_is = false
else      
      if phrase.word == word && phrase.language == language
        @authentication_is = false
      else
         for child in definition.children
            if word == child.word  && language == child.language
              @authentication_is = false
            end ## if word == child.word
          end   ## for child in definition.children  
            
      end ## if phrase.word == word
      end ## if phrase == nil
      @authentication_is
  end ## def authenticate


  
end
