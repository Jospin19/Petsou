class ModifyConfirmationTokenType < ActiveRecord::Migration[6.0]
  def change
    change_column :users, :confirmation_token, :string
  end
end
