class IndexPhrases < ActiveRecord::Migration
  def self.up
    add_index(:phrases, [:word, :language])
  end

  def self.down
    remove_index :phrases, :column => [:word, :language]
  end
end
