class CreateCarouselIssues < ActiveRecord::Migration
  def self.up
    create_table :carousel_issues do |t|
      t.column :issue_id, :integer
      t.column :carousel_id, :integer
      t.column :user_id, :integer
    end
    
    add_index :carousel_issues, :issue_id
    add_index :carousel_issues, :carousel_id
    add_index :carousel_issues, :user_id
  end

  def self.down
    drop_table :carousel_issues
  end
end
