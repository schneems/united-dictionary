class CreateDefinitions < ActiveRecord::Migration
  def self.up
    create_table :definitions do |t|
      t.text :meaning
      t.string :example, :part_of_speech
      t.integer :phrase_id , :rank
      t.timestamp :marked_at
      t.timestamps 
    end
  end

  def self.down
    drop_table :definitions
  end
end
