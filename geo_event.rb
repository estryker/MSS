class GeoEvent < ActiveRecord::Base
  belongs_to :user, :primary_key => :user_email
  
  numeric_regex = /^-?[0-9.]+$/
  
  validates :latitude, :presence => true, 
    :format => {:with => numeric_regex},
    :numericality => {:greater_than_or_equal_to => -90,:less_than_or_equal_to => 90}
  
  validates :longitude, :presence => true,
    :format => {:with => numeric_regex},
    :numericality => {:greater_than_or_equal_to => -180,:less_than_or_equal_to => 180}
  
  validates :text, :presence => true,
    :length       => { :within => 1..140 }
  
  # we'll allow for some slop in this
  #validates :expires, :presence => true,
  #  :date => { :after => Time.now, :before => 24.1.hours.from_now }
  
  validates :duration, :presence => true,
    :numericality => {:greater_than_or_equal_to => 0.0,:less_than_or_equal_to => 24}
end

def closest_active_geo_events(opts)

  center_lat = (opts[:center_latitude] || 0.0).to_f
  center_long = (opts[:center_longitude] || 0.0).to_f
  max = opts[:max].to_i

  # make a bounding box to make the query quicker. 5 degrees in all directions should do the trick
  all_events = GeoEvent.where(["expires_utc > ?",DateTime.now.utc]).
    where(:latitude => (center_lat - 5 .. center_lat + 5),
	  :longitude => (center_long - 5 .. center_long + 5))
    
  # TODO: let the PostGis database do this for us!
  all_events.sort! do |a,b| 
    ((a.latitude - center_lat)**2 + (a.longitude - center_long)**2) <=> ((b.latitude - center_lat)**2 + (b.longitude - center_long)**2)
  end

  all_events.first(max)
end

# TODO: enable some kind of pagination of these if necessary
def user_geo_events(user_email, max= 1000)
  all_events = GeoEvent.where(:user_id => user_email).first(max)
end

def create_geo_event(event)
  # TODO: verify proper merging with 'indifferent_hash' from Sinatra. 
  defaults = {:begins_utc => 0.hours.ago,
    :user_id => 'anaonymous@anonymous.com'}

  geo_event = GeoEvent.new(defaults.merge(event))
  geo_event.expires_utc = geo_event.duration.hours.from_now

  $stderr.puts "GEO EVENT:"
  $stderr.puts geo_event.inspect
  if geo_event.valid?
    geo_event.save
  else
    $stderr.puts "Geo event not valid: #{geo_event.errors.inspect}"
    return nil
  end

  return geo_event
end
