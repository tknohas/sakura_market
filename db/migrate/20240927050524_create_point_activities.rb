class CreatePointActivities < ActiveRecord::Migration[7.1]
  def change
    create_table :point_activities do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :point_change, null: false
      t.string :description
      t.datetime :expires_at

      t.timestamps
    end
  end
end
