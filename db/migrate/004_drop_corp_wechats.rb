class DropCorpWechats < ActiveRecord::Migration
  def drop
    drop_table :corp_wechats
  end
end
