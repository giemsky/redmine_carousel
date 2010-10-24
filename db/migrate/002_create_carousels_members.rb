class CreateCarouselsMembers < ActiveRecord::Migration
  def self.up
    create_table :carousels_members, :id => false do |t|
      t.column :member_id, :integer
      t.column :carousel_id, :integer
    end
    
    add_index :carousels_members, [:carousel_id, :member_id]
  end

  def self.down
    drop_table :carousels_members
  end
end
