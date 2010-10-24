class CreateCarousels < ActiveRecord::Migration
  def self.up
    create_table :carousels do |t|
      t.column :name, :string
      t.column :project_id, :integer
      t.column :period, :integer
      t.column :last_run, :datetime
      t.column :active, :boolean, :default => false
      t.column :auto_assign, :text
    end
    
    add_index :carousels, :project_id
  end

  def self.down
    drop_table :carousels
  end
end
