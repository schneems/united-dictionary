class CreateChildren < ActiveRecord::Migration
  def self.up
    create_table :children do |t|
      t.string :word, :language, :variety
      t.integer :definition_id, :rank
      t.timestamp :marked_at
      t.timestamps 
    end
  end

  def self.down
    drop_table :children
  end
end
