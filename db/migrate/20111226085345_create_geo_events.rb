class CreateGeoEvents < ActiveRecord::Migration
  def self.up
    create_table :geo_events do |t|
      t.float :latitude
      t.float :longitude
      t.datetime :begins_utc
      t.datetime :expires_utc
      t.string :text
      t.float :duration
      t.string :category
      t.string :user_id

      t.timestamps
    end
    add_index :geo_events, :latitude
    add_index :geo_events, :longitude
  end

  def self.down
    drop_table :geo_events
  end
end
