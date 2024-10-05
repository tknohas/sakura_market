class CreateDiaries < ActiveRecord::Migration[7.1]
  def change
    create_table :diaries do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.text :content, null: false
      t.datetime :discarded_at

      t.timestamps
    end
  end
end
