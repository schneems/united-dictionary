class Definition < ActiveRecord::Base
  
  ## validates_presence_of :meaning
  ## validates_presence_of :part_of_speechs
  
  
  has_many :children, :order => 'rank DESC', :dependent => :destroy
  has_many :mugshots, :order => 'rank DESC', :dependent => :destroy
  belongs_to :phrase
  belongs_to :user
  
  validates_presence_of :meaning, :message => "must fill out definition"
  validates_presence_of :part_of_speech, :message => "must check a part of speech"
  
  before_save :format_entries
  
  
  def format_entries
    self.rank = 1 if self.rank == nil
  end
  
  def new_definition_attributes=(definition_attributes) 
    definition_attributes.each do |attributes| 
      definitions.build(attributes) 
    end    
  end 

  def self.find_with_children(def_id)
    Definition.find(:first, :include => [:children], :conditions => {:id => def_id })   
  end
  
  def self.find_top_rank
    find(:all, :include => [:phrase => {:definitions => :children}], :order => 'rank desc', :limit => 20  )
  end
  
  
  def self.find_definition
    find(@def_id)
  end
  
  def user_log(id, login, user)
    if login   
      @definition = Definition.find(id)
      if @definition.user_id == nil
        @definition.update_attributes(:user_id => user.id)
      end
    end
    @definition
  end
end
