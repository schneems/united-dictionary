class CharacterLanguageSupport < ActiveRecord::Migration
  def self.up
    add_column :children, :second_word    , :string
    add_column :children, :third_word  , :string
    add_column :phrases, :second_word     , :string
    add_column :phrases, :third_word     , :string
    add_column :phrases, :pronunciation    , :string
  end

  def self.down
    remove_column :children, :second_word 
    remove_column :children, :third_word  
    remove_column :phrases, :second_word  
    remove_column :phrases, :third_word   
    remove_column :phrases,  :pronunciation
  end
end
