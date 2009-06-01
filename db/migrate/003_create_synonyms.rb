class CreateSynonyms < ActiveRecord::Migration
  def self.up
    create_table :synonyms do |t|
      t.string :word, :language
      t.integer :definition_id, :rank
      t.timestamp :marked_at
      t.timestamps 
    end
  end

  def self.down
    drop_table :synonyms
  end
end
