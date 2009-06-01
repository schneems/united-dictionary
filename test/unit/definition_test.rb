require File.dirname(__FILE__) + '/../test_helper'

class DefinitionTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  def test_truth
    assert true
  end
  
  def test_format_entries
    definition = Definition.new(:meaning => "something", :part_of_speech => "Noun")
    assert definition.save
    assert definition.rank == 1
  end
  
end
