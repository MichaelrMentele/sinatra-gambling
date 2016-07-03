require "sinatra"
require "sinatra/reloader" if development?
require "tilt/erubis"

configure do
  enable :sessions
end

before do 
  session[:user_money] = 100 unless session[:user_money]
end

def valid_bet?(bet)
  bet >= 1 and bet <= session[:user_money]
end

def broke?
  session[:user_money] <= 0
end

#######
# GET #
#######

# Render betting page
get "/" do
  redirect "/broke" if broke?
  erb :guess_and_bet, layout: :layout
end

# Scold the user for gambling
get "/broke" do 
  erb :no_money
end

########
# POST #
########

# Evaluates user guess 
post "/eval_guess" do 
  options = [1, 2, 3]
  random_number = options.sample

  bet = params[:bet].to_i
  unless valid_bet?(bet)
    session[:message] = "Bets must be between $1 and $#{session[:user_money]}."
    redirect "/"
  end

  guess = params[:guess].to_i

  if guess == random_number
    session[:user_money] += bet
    session[:message] = "You have guessed correctly."
  else
    session[:user_money] -= bet
    redirect "/broke" if broke?

    session[:message] = "You guessed #{guess}, but the number was #{random_number}."
  end

  redirect "/"
end
