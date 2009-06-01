class UsersToPhrases < ActiveRecord::Migration
  
  def self.up
      add_column :children, :user_id, :integer
      add_column :definitions, :user_id, :integer
      add_column :phrases, :user_id, :integer
      add_column :users, :rank, :integer
  end
  
  
  def self.down
      remove_column :children, :user_id
      remove_column :definitions, :user_id
      remove_column :phrases, :user_id
      remove_column :users, :rank
  end
end
