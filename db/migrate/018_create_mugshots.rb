class CreateMugshots < ActiveRecord::Migration
  def self.up
    create_table :mugshots do |t|
      t.integer :parent_id
      t.string :content_type
      t.string :filename
      t.string :thumbnail
      t.integer :size
      t.integer :width
      t.integer :height
      t.integer :rank
      t.timestamps
    end
    
    add_column :users, :extra_rank, :integer
    add_column :relateds, :user_id, :integer
    add_column :alternates, :user_id, :integer
    
    
  end

  def self.down
    drop_table :mugshots
    remove_column :users, :extra_rank
    remove_column :relateds, :user_id
    remove_column :alternates, :user_id
  end
end
