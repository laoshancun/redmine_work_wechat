class AddDingtalkAccountNumberToUsers < ActiveRecord::Migration
  def change
    add_column :users, :dingtalk_account_number, :string
  end
end
