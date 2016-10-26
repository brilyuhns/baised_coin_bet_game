class Bet
  def initialize(choice, amount)
    @choice = choice
    @amount = amount
  end

  def choice
    @choice
  end

  def amount
    @amount
  end
end

class Game

  attr_accessor :balance, :bet_amount
  def initialize(strategy)
    @space = [0, 0, 0, 0, 1, 1, 1, 1, 1, 1]
    @balance = 25
    @bets = []
    @outcomes = []
    @strategy = strategy
  end

  def outcome
    @space.sample
  end

  def play
    300.times do
      bet = @strategy.next_bet(@bets, @outcomes)
      current_outcome = outcome
      @bets << bet.choice
      @outcomes << current_outcome
      if bet.choice == current_outcome
        @balance += bet.amount
      else
        @balance -= bet.amount
      end
      # puts "#{{ cur_outcome: current_outcome, bet.choice: bet, balance: @balance }}"
      break if @balance <= 0
    end
  end

  def balance
    @balance
  end
end

class Strategy1
  def next_bet(bets, outcomes)
    Bet.new(1, 5)
  end
end

class Strategy2
  def next_bet(bets, outcomes)
    Bet.new(rand(0..1), 5)
  end
end

class Strategy3
  def next_bet(bets, outcomes)
    return Bet.new(1, 5) if bets.count == 0
    choice = (outcomes.count(1)/outcomes.count.to_f) > 0.6 ? 0 : 1
    Bet.new(choice, 5)
  end
end

def run_for_hundred_games strategy
  games = 100.times.map do
    game = Game.new(instance_eval "#{strategy}.new")
    game.play
    game.balance
  end
  puts "strategy #{strategy}"
  lost_games = games.select{|a| a < 0}
  puts "lost games #{lost_games}"
  avg_balance = games.inject(0){|sum, i| sum+=1 }
  puts "avg_balance: #{avg_balance}"
  puts "min balance: #{games.min}"
  puts "max balance: #{games.max}"
end

run_for_hundred_games(Strategy1)
run_for_hundred_games(Strategy2)
run_for_hundred_games(Strategy3)
