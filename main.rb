require 'rubygems'
require 'sinatra'

set :sessions, true

BLACKJACK_AMOUNT = 21
DEALER_MINIMUM_HIT_AMOUNT = 17
INITIAL_PLAYER_BANLROLL = 500

helpers do
  def calculate_total(cards)
    card_values = cards.map{|element| element[1]}

    total = 0
    card_values.each do |value|
      if card_values == "A"
        total += 11
      else
        total += value.to_i == 0 ? 10 : value.to_i
      end
    end

    # Correct for Aces
    card_values.select{|element| element == "A"}.count.times do
      break if total <= BLACKJACK_AMOUNT
      total -= 10
    end
    
    total
  end

  def card_image(card)
    suit = case card[0]
           when 'H' then 'hearts'
           when 'D' then 'diamonds'
           when 'C' then 'clubs'
           when 'S' then 'spades'
           end

    value = card[1]
    if ['J', 'Q', 'K', 'A'].include?(value)
      value = case card[1]
              when 'J' then 'jack'
              when 'Q' then 'queen'
              when 'K' then 'king'
              when 'A' then 'ace'
              end
    end
    
    "<img src='/images/cards/#{suit}_#{value}.jpg' class='card_image'>"
  end

  def winner!(msg)
    @play_again = true
    @show_hit_or_stand_buttons = false
    session[:player_bankroll] = session[:player_bankroll].to_i + session[:bet_amount].to_i
    @success = "<strong>#{session[:player_name]} wins!</strong> <br />#{msg} You won $#{session[:bet_amount]}, so you now have $#{session[:player_bankroll]}."
  end

  def loser!(msg)
    @play_again = true
    @show_hit_or_stand_buttons = false
    session[:player_bankroll] = session[:player_bankroll].to_i - session[:bet_amount].to_i
    @error = "<strong>#{session[:player_name]} loses.</strong> <br /> #{msg} You lost $#{session[:bet_amount]}, so you now have $#{session[:player_bankroll]}."
    if session[:player_bankroll].to_i == 0
      @play_again = false
      @player_leave_table = true
    end
  end

  def tie!(msg)
    @play_again = true
    @show_hit_or_stand_buttons = false
    @success = "<strong>It's a tie!</strong> #{msg}"
  end
end

before do
  @show_hit_or_stand_buttons = true
end

get '/' do
  if session[:player_name]
    redirect '/game'
  else
    redirect '/new_player'
  end
end

get '/new_player' do
  erb :new_player
end

post '/new_player' do
  if params[:player_name].empty? || params[:player_name].to_i != 0
    @error = "Please enter your name."
    halt erb(:new_player)
  else
    session[:player_name] = params[:player_name]
    session[:player_bankroll] = INITIAL_PLAYER_BANLROLL
    redirect '/bet'
  end
end

get '/bet' do
  erb :bet
end

post '/bet' do
  if session[:player_bankroll].to_i == 0
    redirect '/no_money'
  elsif params[:bet_amount].empty? || params[:bet_amount].to_i == 0 
    @error = "You must place a bet."
    halt erb(:bet)
  elsif (params[:bet_amount].to_i < 5) || (params[:bet_amount].to_i > session[:player_bankroll].to_i)
    @error = "Your bet must be between $5 and $#{session[:player_bankroll]}."
    halt erb(:bet)
  else
    session[:bet_amount] = params[:bet_amount]
    redirect '/game'
  end  

end

get '/game' do
  session[:turn] = session[:player_name]
  
  # create a deck and put it in session

  suits = ["H", "D", "C", "S"]
  values = ["2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A"]
  session[:deck] = suits.product(values).shuffle!
  
  # deal cards
  session[:dealer_cards] = []
  session[:player_cards] = []
  session[:dealer_cards] << session[:deck].pop
  session[:player_cards] << session[:deck].pop
  session[:dealer_cards] << session[:deck].pop
  session[:player_cards] << session[:deck].pop

  erb :game
end

post '/game/player/hit' do
  session[:player_cards] << session[:deck].pop

  player_total = calculate_total(session[:player_cards])
  
  if player_total == BLACKJACK_AMOUNT
    winner!("#{session[:player_name]} hit Blackjack!")
  elsif player_total > BLACKJACK_AMOUNT
    loser!("#{session[:player_name]} busted at #{player_total}.")
  end

  erb :game, layout: false
end

post '/game/player/stand' do
  @success = "#{session[:player_name]} stands."
  @show_hit_or_stand_buttons = false
  redirect '/game/dealer'
end

get '/game/dealer' do
  session[:turn] = "dealer"
  @show_hit_or_stand_buttons = false

  dealer_total = calculate_total(session[:dealer_cards])

  if dealer_total == BLACKJACK_AMOUNT
    loser!("Dealer hit Blackjack.")
  elsif dealer_total > BLACKJACK_AMOUNT
    winner!("Dealer busted at #{dealer_total} .")
  elsif dealer_total >= DEALER_MINIMUM_HIT_AMOUNT
    redirect '/game/compare'
  else
    @show_dealer_hit_button = true
  end

  erb :game
end


post '/game/dealer/hit' do
  session[:dealer_cards] << session[:deck].pop
  redirect '/game/dealer'
end

get '/game/compare' do
  @show_hit_or_stand_buttons = false

  player_total = calculate_total(session[:player_cards])
  dealer_total = calculate_total(session[:dealer_cards])

  if player_total < dealer_total
    loser!("#{session[:player_name]} stands at #{player_total}, and the dealer stands at #{dealer_total}.")
  elsif player_total > dealer_total
    winner!("#{session[:player_name]} stands at #{player_total}, and the dealer stands at #{dealer_total}.")
  else
    tie!("Both #{session[:player_name]} and the dealer stand at #{player_total}.")
  end

  erb :game
end

get '/no_money' do
  erb :no_money
end

get '/game_over' do
  erb :game_over
end


