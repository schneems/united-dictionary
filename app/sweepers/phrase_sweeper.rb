class PhraseSweeper < ActionController::Caching::Sweeper
    observe Phrase
  #  observe Definition
    
  def after_save(phrase)
    expire_cache(phrase)
  end
  
  def after_destroy(phrase)
    expire_cache(phrase)
  end
  
  def after_update(phrase)
    expire_cache(phrase)
  end
  
  
  def expire_cache(phrase)
    #1.upto(5) {|i|  expire_fragment(:action => 'index', :page => i ) } 
    ## 1.upto(5) {|i|  fragment_exist?(:action => 'index', :page => i ) ? expire_fragment(:action => 'index', :page => i ) : nil } 
    # sleep 10
    expire_fragment(:action => 'show', :word => phrase.word, :language => phrase.language)   
    puts phrase.word
    expire_fragment(%r{.*})
    expire_fragment(%r{phrases/recently_added.*}) ## checked out
    expire_fragment(%r{phrases/top_slang.*}) ## checked out
    ## 1.upto(2500) {|i|  expire_fragment(:action => 'a_z', :page => i, :ltr => 'All') } 
    expire_fragment(%r{phrases/a_z.*}) ## checked out    
  end
  
  

  
  
  
end