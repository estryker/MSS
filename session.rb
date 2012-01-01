require './helpers/session_helper.rb'

def create_session(format = :xml)
  user = User.authenticate(params[:session][:email],
			   params[:session][:password])
end

