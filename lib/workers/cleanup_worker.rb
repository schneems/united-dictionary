class CleanupWorker < BackgrounDRb::MetaWorker
  set_worker_name :cleanup_worker
  
  def create(args = nil)
    # this method is called, when worker is loaded for the first time
  end
  
  def delete_elements(args = nil)
    logger.info "***** STARTING CLEANUP PROCESS *****"    
    @phrases = Phrase.find(:all, :order => "rank DESC")
    for phrase in @phrases
      for comment in phrase.comments
        @item = comment
        check_for_delete
      end ## for comment ## dependent phrase
      for mugshot in phrase.mugshots
        @item = mugshot
        check_for_delete
      end ## for mugshot ## dependent phrase
      for definition in phrase.definitions
          for child in definition.children
            @item = child
            check_for_delete
          end ## for child ## dependent definition
          @item = definition
          check_for_delete
      end ## for definition ## dependent phrase
        @item = phrase
        check_for_delete
    end ## for phrases
        logger.info "***** FINSHING CLEANUP PROCESS *****"
        logger.info "***** STARTING USER RANK PROCESS *****"
  end ## def delete_elements
  
  
  
  def check_for_delete(args = nil) # GOOD
    if @item.marked_at != nil && Time.now-@item.marked_at > 5 ##1800
      if @item.rank > -1
        @item.marked_at = nil
        @item.save!
      end
      if @item.rank < 0 && @item.rank != nil
        logger.info " Deleting #{@item} ranked #{@item.rank}"
        @item.destroy
        logger.info "deleting element now"
      end # if @item.rank > 1
    end # if @item.marked_at
  end #def check_for delete
  
  
  
  def rank_my_users
  end ## def rank_my_users

end

