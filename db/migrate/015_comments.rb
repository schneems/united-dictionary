class Comments < ActiveRecord::Migration
  def self.up
      create_table :comments do |t|
        t.text :comment_field
        t.string :name
        t.integer :phrase_id , :rank
        t.timestamp :marked_at
        t.timestamps 
      end

    end

    def self.down

      drop_table :comments
    end
  end
