class AddActivationToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :rails, :string
    add_column :users, :generate, :string
    add_column :users, :migration, :string
    add_column :users, :add_activation_to_users, :string
    add_column :users, :rails, :string
    add_column :users, :generate, :string
    add_column :users, :migration, :string
    add_column :users, :add_activation_to_users, :string
    add_column :users, :activation_digest, :string
    add_column :users, :activated, :boolean, default: false
    add_column :users, :activated_at, :datetime
  end
end
