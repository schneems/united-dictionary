namespace :language do 
  
  desc "gets all files forever"
  task :download_all => :environment do
    language_array = ["russian", "dutch", "french", "german", "greek", "italian", "japanese", "korean", "portuguese",  "spanish", "english"]
    for element in language_array
      @lang_to = element
      open('public/language/'+@lang_to.to_s+'.txt', "w") do |file|
        
          file.puts "This work is licensed under the Creative Commons Attribution-Noncommercial-Share Alike 3.0 United 
States License. To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/us/ 
or send a letter to Creative Commons, 171 Second Street, Suite 300, San Francisco, California, 94105, USA.
This file was generated from www.slangslang.com in part by Think Bohemian and Richard Schneeman."

          file.puts "This File Updated: #{Time.now.to_s(:my_time)}
          
          "
      end ## open
      download_languages
            File.open('public/language/'+@lang_to.to_s+'.txt.gz', 'w+') do |f|
              gz = Zlib::GzipWriter.new(f)
                  File.open('public/language/'+@lang_to.to_s+'.txt', 'r').each do |line|
                      gz.write line
                  end
              gz.close
            end
            File.delete('public/language/'+@lang_to.to_s+'.txt')
    end
  end

  
  
  def download_languages
    @time = Time.now
    all_english_phrases = Phrase.find(:all, :include => [:definitions => :children ], :conditions => {:language => "#{@lang_to.capitalize}"}, :order => "word ASC")
    for phrase in all_english_phrases
      
      for definition in phrase.definitions
        child_array = []
        
          definition.children.each{ |child| child_array << child if child.language == "English"}
          

          
          
          if !child_array.empty?
            synonyms = child_array.collect{|child| child.word.to_s+", " if child.variety == "synonym" }
            antonyms = child_array.collect{|child| child.word.to_s+", " if child.variety == "antonym" }
            synonyms = [] if antonyms == nil 
            antonyms = [] if antonyms == nil 
            
            example = definition.example || ""
            
            
            open('public/language/'+@lang_to.to_s+'.txt', 'a') do |file|
                file.puts "Word: " + phrase.word + " (" + definition.part_of_speech +  ")  Rank:" + phrase.rank.to_s + " "+ definition.meaning + "- "  + example + " Synonyms: "  + synonyms.to_s + " Antonyms: " + antonyms.to_s + " "
            end ## open
          end # if !child_array.empty?
      end ## for def in phrase.def
    end ## for phrase in all_english_phrases
    
  end
  
  
end