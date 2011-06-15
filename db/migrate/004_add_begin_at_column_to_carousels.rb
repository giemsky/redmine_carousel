class AddBeginAtColumnToCarousels < ActiveRecord::Migration
	def	self.up
		add_column :carousels, :begin_at, :datetime, :null => false
		ActiveRecord::Base.connection.execute("update carousels set begin_at = '1970-01-01'")
	end

	def	self.down
		remove_column :carousels, :begin_at
	end
end
