class PhrasesToMugshots < ActiveRecord::Migration
  def self.up
    add_column :mugshots, :phrase_id, :integer
    add_column :mugshots, :user_id, :integer
    add_column :mugshots, :marked_at, :timestamp
  end

  def self.down
    remove_column :mugshots, :phrase_id
    remove_column :mugshots, :user_id
    remove_column :mugshots, :marked_at
  end
end
