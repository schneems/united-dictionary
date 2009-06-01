## cript/generate migration rank_me


class CreatePhrases < ActiveRecord::Migration
  def self.up
    create_table :phrases do |t|
      t.string :word, :language
      t.integer :rank
      t.timestamp :marked_at
      t.timestamps 
    end
  end

  def self.down
    drop_table :phrases
  end
end
