require File.dirname(__FILE__) + '/../test_helper'

#ruby test/unit/phrase_test.rb

class PhraseTest < Test::Unit::TestCase
  # Replace this with your real tests.
  fixtures :phrases 
  
  
  def test_truth
    assert true
  end
  
  
  def test_presence_of_word_for_phrase
    phrase = Phrase.new(:language => "English")
    assert !phrase.valid?
    assert phrase.errors.invalid?(:word)
    phrase = Phrase.new(:word => "testingtesting", :rank => 1)
    assert !phrase.valid?
    assert phrase.errors.invalid?(:language)
  end
  
  
  def test_validate_not_spam_for_phrase
    phrase = Phrase.new(:word => "[/url]", :language => "English", :rank =>1)
    assert !phrase.valid?
    phrase = Phrase.new(:word => "asdfasdf[/url]asdfasdf", :language => "English", :rank =>1)
    assert !phrase.valid?
    phrase = Phrase.new(:word => "[/URL]", :language => "English", :rank =>1)
    assert !phrase.valid?
    phrase = Phrase.new(:word => "[/URL]asdfasdf", :language => "English", :rank =>1)
    assert !phrase.valid?
    phrase = Phrase.new(:word => "asdfasdf[/URL]", :language => "English", :rank =>1)
    assert !phrase.valid?
    phrase = Phrase.new(:word => "asdfasdf/URL", :language => "English", :rank =>1)
    assert phrase.valid?
  end
  
  def test_unique_word
    phrase = Phrase.new(:word => phrases(:duplicate_phrase).word, :language => phrases(:duplicate_phrase).language, :rank =>1)
    assert !phrase.save
    phrase = Phrase.new(:word => phrases(:duplicate_phrase).word, :language => "Spanish", :rank =>1)
    assert phrase.valid?
  end
  
  def test_format_entries
    phrase = Phrase.new(:word => " Bad     EnTry ", :language => "English")
    phrase.save
    assert phrase.save
    assert phrase.word == "bad entry"
    assert phrase.rank == 1
    phrase = Phrase.create(:word => " Bad     EnTry  two ", :language => "English")
    assert phrase.save
    assert phrase.word == "bad entry two"
    assert phrase.rank == 1
    phrase = Phrase.create(:word => " Bad     EnTry  three ", :second_word => " bad     Entry ", :third_word => "bad    entRy  ", :language => "English")
    assert phrase.save
    assert phrase.word == "bad entry three"
    assert phrase.second_word == "bad entry"
    assert phrase.third_word == "bad entry"
    assert phrase.rank == 1
  end
  
 #  validates_uniqueness_of :word, :case_sensitive => true, :scope => :language, :message => " or Entry and language pair is already in the database"
 
end
