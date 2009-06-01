class CreateRelateds < ActiveRecord::Migration
  def self.up
    create_table :relateds do |t|
      t.string :word, :language
      t.integer :phrase_id, :rank
      t.timestamp :marked_at
      t.timestamps
    end
  end

  def self.down
    drop_table :relateds
  end
end
