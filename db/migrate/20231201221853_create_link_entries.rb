class CreateLinkEntries < ActiveRecord::Migration[7.1]
  def change
    create_table :link_entries do |t|
      t.string :short_id, null: false, index: { unique: true }
      t.string :external_url, null: false

      t.timestamps
    end
  end
end
