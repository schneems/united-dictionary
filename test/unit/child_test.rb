require File.dirname(__FILE__) + '/../test_helper' 


class ChildTest < Test::Unit::TestCase
  fixtures :children 
  
  

#require RAILS_ROOT + '/vendor/plugins/acts_as_solr/test/solr_test_helper.rb'

## ruby test/unit/child_test.rb


  # class ChildTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  def test_truth
    setup
    assert true
  end
  
  
  def test_presence_of_word_for_child
    child = Child.new
    assert !child.valid?
    assert child.errors.invalid?(:word)    
  end
  
  def test_valid_url_child
    child = Child.new(:word => "[/url]", :language => "English", :rank =>1)
    assert !child.valid?
    child = Child.new(:word => "asdfasdf[/url]asdfasdf", :language => "English", :rank =>1)
    assert !child.valid?
    child = Child.new(:word => "[/URL]", :language => "English", :rank =>1)
    assert !child.valid?
    child = Child.new(:word => "[/URL]asdfasdf", :language => "English", :rank =>1)
    assert !child.valid?
    child = Child.new(:word => "asdfasdf[/URL]", :language => "English", :rank =>1)
    assert !child.valid?
    child = Child.new(:word => "asdfasdf/URL", :language => "English", :rank =>1)
    assert child.valid?
  end
  
  def test_unique_child
    
    child = Child.new(:word => children(:duplicate_child).word, 
                      :language => children(:duplicate_child).language,
                      :variety => children(:duplicate_child).variety,
                      :definition_id => children(:duplicate_child).definition_id,
                      :rank =>1)

    assert !child.save
    
    child = Child.new(:word => "different word", 
                      :language => children(:duplicate_child).language,
                      :variety => children(:duplicate_child).variety,
                      :definition_id => children(:duplicate_child).definition_id,
                      :rank =>1)

    assert child.save
    
    child = Child.new(:word => children(:duplicate_child).word, 
                      :language => children(:duplicate_child).language,
                      :variety => children(:duplicate_child).variety,
                      :definition_id => 0,
                      :rank =>1)

    assert child.save
    
    child = Child.new(:word => children(:duplicate_child).word, 
                      :language => "Spanish",
                      :variety => children(:duplicate_child).variety,
                      :definition_id => children(:duplicate_child).definition_id,
                      :rank =>1)

    assert child.save
    
    
        
  end
  
  
  def test_create_phrase_for_child
    child = children(:breast_synonym)
    phrase = Phrase.find(:first, :conditions => {:word => child.word, :language => child.language})
    assert phrase == nil 
    child.create_phrase_for_child
    phrase = Phrase.find(:first, :conditions => {:word => child.word, :language => child.language})
    assert phrase.word == child.word  
    assert phrase.definitions[0].meaning == child.definition.meaning
    0.upto(phrase.definitions[0].children.size-1) do |count|
      assert phrase.word != phrase.definitions[0].children[count].word
    end
    child = children(:breast_antonym)
    phrase = Phrase.find(:first, :conditions => {:word => child.word, :language => child.language})
    assert phrase == nil
    child.create_phrase_for_child
    phrase = Phrase.find(:first, :conditions => {:word => child.word, :language => child.language})
    assert phrase.word == child.word
    assert phrase.definitions[0] == nil 
  end
  
  def test_populate_all_child_phrases
    child = children(:breast_synonym)
      phrase = Phrase.find(:first, :conditions => {:word => child.word, :language => child.language})
      assert phrase == nil 
    child.populate_all_child_phrases
    phrase = Phrase.find(:first, :conditions => {:word => child.word, :language => child.language})
    assert phrase.word == child.word

   for child in child.definition.children
   ## problem is a phrase >> definiton >> child.word == phrase.word
   phrase = Phrase.find(:first, :conditions => {:word => child.word, :language => child.language})
   assert phrase.word == child.word
       if child.variety != "antonym"
         assert phrase.definitions[0].meaning == child.definition.meaning 
         assert !phrase.definitions[0].children.collect{|child| child.word }.include?(phrase.word) unless children(:breast_synonym_same_as_phrase).word == phrase.word
       end
    end
  end
  
  def test_format_entries
    child = Child.new(:word => " Bad     EnTry ", :language => "English")
    child.save
    assert child.save
    assert child.word == "bad entry"
    assert child.rank == 1
    child = Child.create(:word => " Bad     EnTry  two ", :language => "English")
    assert child.save
    assert child.word == "bad entry two"
    assert child.rank == 1
    child = Child.create(:word => " Bad     EnTry  three ", :second_word => " bad     Entry ", :third_word => "bad    entRy  ", :language => "English")
    assert child.save
    assert child.word == "bad entry three"
    assert child.second_word == "bad entry"
    assert child.third_word == "bad entry"
    assert child.rank == 1
  end
  
  
    
    
    
    
end
