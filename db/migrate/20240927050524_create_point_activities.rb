class CreatePointActivities < ActiveRecord::Migration[7.1]
  def change
    create_table :point_activities do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :point_change, null: false
      t.string :description

      t.timestamps
    end
  end
end
