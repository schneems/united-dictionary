class ChildSweeper < ActionController::Caching::Sweeper
    #observe Phrase
    observe Child
    
  def after_save(child)
    expire_cache(child)
  end
  
  def after_destroy(child)
    expire_cache(child)
  end
  
  def after_update(child)
    expire_cache(child)
  end
  
  
  def expire_cache(child)
    #1.upto(5) {|i|  expire_fragment(:action => 'index', :page => i ) } 
    ## 1.upto(5) {|i|  fragment_exist?(:action => 'index', :page => i ) ? expire_fragment(:action => 'index', :page => i ) : nil } 
    
    expire_fragment(:action => 'show', :word => child.definition.phrase.word, :language => child.definition.phrase.language)   
    
    expire_fragment(%r{.*})
    expire_fragment(%r{phrases/recently_added.*}) ## checked out
    expire_fragment(%r{phrases/top_slang.*}) ## checked out
    ## 1.upto(2500) {|i|  expire_fragment(:action => 'a_z', :page => i, :ltr => 'All') } 
    expire_fragment(%r{phrases/a_z.*}) ## checked out    
  end
  
  

  
  
  
end