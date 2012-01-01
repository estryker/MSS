xml.squeaks do 
  @squeak_list.each do | squeak |  
      xml.squeak do 
      xml.id squeak.id 
      xml.latitude squeak.latitude
      xml.longitude squeak.longitude
      xml.text squeak.text
      xml.expires squeak.expires_utc
    end 
  end
end
