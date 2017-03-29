class CreateCorpWechats < ActiveRecord::Migration
  def change
    create_table :corp_wechats do |t|
      t.string :corp_id
      t.string :corp_secret
      t.integer :app_id
      t.string :corp_name
      t.string :app_name
      t.timestamps null: false
      t.integer :author_id, index: true
      t.integer :project_id, index: true
    end
  end
end
