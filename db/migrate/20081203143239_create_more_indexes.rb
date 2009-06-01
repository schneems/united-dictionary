  class CreateMoreIndexes < ActiveRecord::Migration
    def self.up
 
       add_index(:phrases,[:user_id])
       add_index(:phrases, [:created_at] )
     
       add_index(:comments, [:id] )
       add_index(:comments, [:phrase_id])
     
       add_index(:mugshots, [:id] )
       add_index(:mugshots, [:phrase_id])
     
       add_index(:definitions, [:rank])
       add_index(:definitions, [:phrase_id])
       add_index(:definitions, [:user_id])
     
       add_index(:users, [:id] )
  
    end

    def self.down
    
        remove_index :phrases, :column => [:user_id]
        remove_index :phrases, :column => [:created_at]
       
        remove_index :comments, :column => [:id]
        remove_index :comments, :column => [:phrase_id]
       
       
        remove_index :mugshots, :column => [:id]
         remove_index :mugshots, :column => [:phrase_id]
      
        remove_index :definitions, :column => [:rank]
        remove_index :definitions, :column => [:phrase_id]
        remove_index :definitions, :column => [:user_id]
      
        remove_index :users, :column => [:id]
 

  end
end
