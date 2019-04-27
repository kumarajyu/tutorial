class AddStatusToMessages < ActiveRecord::Migration[5.1]
  def change
    add_column :messages, :from_id, :integer
  end
end
