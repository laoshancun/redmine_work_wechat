class AddDingtalkDingidToUsers < ActiveRecord::Migration
  def change
    add_column :users, :dingtalk_dingid, :string
  end
end
