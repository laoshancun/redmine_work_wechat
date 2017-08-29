class AddCorpWechatAccountNumberToUsers < ActiveRecord::Migration
  def change
    add_column :users, :corp_wechat_account_number, :string
  end
end
