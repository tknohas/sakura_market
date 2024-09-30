class AddVendorIdToPurchaseItems < ActiveRecord::Migration[7.1]
  def change
    add_reference :purchase_items, :vendor, null: false, foreign_key: true
  end
end
