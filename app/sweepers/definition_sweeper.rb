class DefinitionSweeper < ActionController::Caching::Sweeper
    #observe Phrase
    observe Definition
    
  def after_save(definition)
    expire_cache(definition)
  end
  
  def after_destroy(definition)
    expire_cache(definition)
  end
  
  def after_update(definition)
    expire_cache(definition)
  end
  
  
  def expire_cache(definition)
    #1.upto(5) {|i|  expire_fragment(:action => 'index', :page => i ) } 
    ## 1.upto(5) {|i|  fragment_exist?(:action => 'index', :page => i ) ? expire_fragment(:action => 'index', :page => i ) : nil } 
    
    expire_fragment(:action => 'show', :word => definition.phrase.word, :language => definition.phrase.language)   
    
    expire_fragment(%r{.*})
    expire_fragment(%r{phrases/recently_added.*}) ## checked out
    expire_fragment(%r{phrases/top_slang.*}) ## checked out
    ## 1.upto(2500) {|i|  expire_fragment(:action => 'a_z', :page => i, :ltr => 'All') } 
    expire_fragment(%r{phrases/a_z.*}) ## checked out    
  end
  
  

  
  
  
end