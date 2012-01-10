require 'koala'

def squeak_static_url(squeak)
  "http://maps.googleapis.com/maps/api/staticmap?center=#{squeak.latitude},#{squeak.longitude}&zoom=13&size=200x200&maptype=roadmap&markers=color:blue%7Clabel:M%7C#{squeak.latitude},#{squeak.longitude}&sensor=true"
end

def squeak_to_facebook(squeak,access_token,mapsqueak_host)
  user = Koala::Facebook::GraphAPI.new(access_token)
  picture_url = squeak_static_url(squeak)
  
  puts "Google image url: #{picture_url}"
  
  # Use google's static map api to get an image for the squeak
  id = user.put_wall_post("MapSqueak update at #{Time.now.strftime('')}",{:name => 'squeak name', 
			    :link => "#{mapsqueak_host}/squeaks/#{squeak.id}",
			    :caption => squeak.text,
			    :description => "the description of the squeak, TBD",
			    :picture => picture_url})
  puts "Updated facebook  with id: #{id}"

end
