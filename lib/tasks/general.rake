namespace :general do 

  
  desc "downcases all phrases and takes out all spaces"
  task :kill_phrase_spacing => :environment do
  @time = Time.now
  Phrase.find(:all).each {|phrase| phrase.word.downcase.strip.squeeze(" ") && phrase.save}

  @time = Time.now
  Children.find(:all).each {|child| child.word.downcase.strip.squeeze(" ") && child.save}
  end
  
  
  
  desc "changes russian to Russian"
  task :port_spelling => :environment do
    @phrases = Child.find(:all, :conditions => {:language => 'Portugese'})
    for phrase in @phrases
      phrase.update_attributes(:language => "Portuguese")
    end
    @phrases = Phrase.find(:all, :conditions => {:language => 'Portugese'})
    for phrase in @phrases
      phrase.update_attributes(:language => "Portuguese")
    end
    
  end
  
  desc "fixes the rank"
  task :rank_fix => :environment do
    @phrases = Phrase.find(:all, :conditions => {:rank => nil })
    for phrase in @phrases
      phrase.update_attributes(:rank => 1)
    end
  end
  
  desc "Kills all definitions with no children"
  task :kill_def_puma => :environment do
        @definitions = Definition.find(:all, :include => [:children], :limit => 5000, :conditions => {:meaning => 'puma, cougar, '})    
        for definition in @definitions
          if definition.children.size == 0
            definition.destroy
          end
        end
  end
  
  
  
  desc "Kills all definitions with no children"
  task :kill_def => :environment do
    @all_definitions = Definition.find(:all).size
    0.upto(@all_definitions/10000) do |number|
        @definitions = Definition.find(:all, :include => [:children], :limit => 10000, :offset => number*10000)    
        for definition in @definitions
          if definition.children.size == 0
           
            definition.destroy
          end
        end
    end
  end
  
  desc "Kills all definitions with no children"
  task :count_phrase => :environment do
    @phrases = Phrase.find(:all)

    
  end
  
  
  
  desc "cleans up all deleted items"
    task :cleanup => :environment do
        @phrases = Phrase.find(:all, :conditions => "phrases.marked_at IS NOT NULL")
        @definitions = Definition.find(:all, :conditions => "definitions.marked_at IS NOT NULL")
        @children = Child.find(:all, :conditions => "children.marked_at IS NOT NULL")
        @comments = Comment.find(:all, :conditions => "comments.marked_at IS NOT NULL")
        @mugshots = Mugshot.find(:all, :conditions => "mugshots.marked_at IS NOT NULL")
        for phrase in @phrases
          @item = phrase
          check_for_delete
        end
        
        for comment in @comments
          @item = comment
          check_for_delete
        end
          
        for mugshot in @mugshots
          @item = mugshot
          check_for_delete
        end ## for mugshot ## dependent phrase
        
        for definition in @definitions
          @item = definition
          check_for_delete
        end
        
        for child in @children
          @item = child
          check_for_delete
        end
    end ## task
    
    
    def check_for_delete(args = nil) # GOOD
      if @item.marked_at != nil && Time.now-@item.marked_at > 1800
        if @item.rank > -1
          @item.marked_at = nil
          @item.save!
        end
        if @item.rank < 0 && @item.rank != nil
          @item.destroy
        end # if @item.rank > 1
      end # if @item.marked_at
    end #def check_for delete
    
    
    
end ##namespace