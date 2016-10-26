@space = [0, 0, 0, 0, 1, 1, 1, 1, 1, 1]
def outcome
  @space.sample
end


def play_game strategy, bet_amount
  balance = 25
  strategy.each do |bet|
    cur_outcome = outcome
    puts bet: bet
    if bet == cur_outcome
      balance += bet_amount
    else
      balance -= bet_amount
    end
    puts "#{{ cur_outcome: cur_outcome, bet: bet, balance: balance }}"
    break if balance <= 0
  end
  puts ">>>>>>>>Final Balance in game: #{balance} <<<<<<<<<<<<"
  balance
end

def strategy1
  Enumerator.new{|a| 300.times{a << 1} }
end

play_game(strategy1, 5)
i=0

data_for_100_games = 100.times.map{ i+=1; puts "Game #{i}"; play_game(strategy1, 5) }
lost_games = data_for_100_games.select{|a| a<= 0}.count
puts "Lost #{lost_games} out of 100"
average = data_for_100_games.inject(0){|sum, a| sum+= a} / 100.0
puts "Average balance of 100 games #{average}"


# def strategy2 game_so_far

# end
