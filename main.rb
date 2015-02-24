require 'rubygems'
require 'sinatra'
require 'shotgun'

set :sessions, true

helpers do
  def calculate_total(cards)
    array = cards.map{|element| element[1]}

    total = 0
    array.each do |a|
      if a == "A"
        total += 11
      else
        total += a.to_i == 0 ? 10 : a.to_i
      end
    end

    # Correct for Aces
    array.select{|element| element == "A"}.count.times do
      break if total <= 21
      total -= 10
    end
    
    total
  end
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
  session[:player_name] = params[:player_name]
  redirect '/game'
end

get '/game' do
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
  
  if player_total == 21
    @success = "Congratulations, #{session[:player_name]}! You hit Blackjack!"
    @show_hit_or_stand_buttons = false
  elsif player_total > 21
    @error = "Sorry, #{session[:player_name]}, you've busted."
    @show_hit_or_stand_buttons = false
  end

  erb :game
end

post '/game/player/stand' do
  @success = "#{session[:player_name]} stands."
  @show_hit_or_stand_buttons = false
  erb :game
end

post '/game/dealer/hit' do
  session[:player_cards] << session[:deck].pop

  dealer_total = calculate_total(session[:dealer_cards])
  erb :game

  
  if dealer_total == 21
    @success = "Dealer hit Blackjack. Sorry, #{session[:player_name]}, you lose."
  elsif dealer_total > 21
    @error = "Dealer busted. Congratulations, #{session[:player_name]}, you win!"
  end
end
