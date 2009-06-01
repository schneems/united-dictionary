class DefinitionIndex < ActiveRecord::Migration
  def self.up
    add_index(:definitions, [:id] )
    add_index(:children,[:definition_id])
    add_index(:children,[:id])
  end

  def self.down
    remove_index :definitions, :column => [:id]
    

    
    remove_index :children, :column => [:definition_id]
    remove_index :children, :column => [:id]
    
  end
end
