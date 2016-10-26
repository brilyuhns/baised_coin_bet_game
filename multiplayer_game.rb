class MultiplayerGame
  def initialize players
    @space = [0, 0, 0, 0, 1, 1, 1, 1, 1, 1]
    @game = @game
    @players = players
    @outcomes = []
  end

  def toss
    @space.sample
  end

  def play
    300.times do
      @outcomes << toss
      valid_players.each do |player|
        calculate_outcome(player, @outcomes.last)
      end
    end
  end

  def calculate_outcome(player, toss)
    bet = player.next_bet(@outcomes)
    if bet.choice == toss
      # puts "Player: #{player}; Bet: #{bet}; outcomes: #{@outcomes}; win"
      player.add_to_balance(bet.amount)
    else
      # puts "Player: #{player}; Bet: #{bet}; outcomes: #{@outcomes}; lose"
      player.deduct_from_balance(bet.amount)
    end
  end

  def valid_players
    @players.reject(&:is_bankrupt?)
  end
end

class Player
  attr_accessor :strategy
  def initialize strategy, strategy_options={}
    @strategy = strategy.new(strategy_options)
    @balance = 25
    @bets = []
  end

  def balance
    @balance
  end

  def next_bet(outcomes)
    @bets << @strategy.next_bet(@bets, outcomes, balance)
    @bets.last
  end

  def is_bankrupt?
    @balance <= 0
  end

  def deduct_from_balance amount
    @balance -= amount
  end

  def add_to_balance amount
    @balance += amount
  end

  def to_s
    str = ["strategy: #{@strategy}"]
    str << "balance: #{balance}"
    str.join("\n")
  end
end


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

  def to_s
    "choice: #{@choice}; amount: #{@amount}"
  end
end

class Strategy
  def initialize(options); end
  def to_s
    self.class.name
  end
end
class AlwaysHeads < Strategy
  def next_bet(bets, outcomes, balance)
    Bet.new(1, 5)
  end
end

class RandomBet < Strategy
  def next_bet(bets, outcomes, balance)
    Bet.new(rand(0..1), 5)
  end
end

class ProbabilityBasedBet < Strategy
  def next_bet(bets, outcomes, balance)
    return Bet.new(1, 5) if bets.count == 0
    choice = (outcomes.count(1)/outcomes.count.to_f) > 0.6 ? 0 : 1
    Bet.new(choice, 5)
  end
end

class ProbabilityAndBetAmount < Strategy
  def initialize(options={})
    @percent = options.fetch(:percent){ 0.3 }
    @rounding_function = options.fetch(:rounding_function){ :ceil }
  end

  def next_bet(bets, outcomes, balance)
    return Bet.new(1, 5) if bets.count == 0
    choice = (outcomes.count(1)/outcomes.count.to_f) > 0.6 ? 0 : 1
    amount = (balance*@percent)
    amount = amount.send(@rounding_function) if @rounding_function != :none
    Bet.new(choice, amount)
  end

  def to_s
    "ProbabilityAndBetAmount to #{@percent} with #{@rounding_function}"
  end
end


def run_game
    players = []
    players << Player.new(AlwaysHeads)
    players << Player.new(RandomBet)
    players << Player.new(ProbabilityBasedBet)
    players << Player.new(ProbabilityAndBetAmount)
    players << Player.new(ProbabilityAndBetAmount, { percent: 0.2 })
    players << Player.new(ProbabilityAndBetAmount, { percent: 0.2, rounding_function: :none })
    game = MultiplayerGame.new(players)
    game.play
    players
end


def analyse
  no_of_runs = 1000
  all_games = no_of_runs.times.map{run_game}
  all_games.first.each_with_index do |games, idx|
    all_games_for_player = all_games.map{|a| a[idx]}
    loses = all_games_for_player.count(&:is_bankrupt?)
    avg = all_games_for_player.inject(0){|sum, player| sum += player.balance }/no_of_runs.to_f
    # puts all_games_for_player.map(&:balance)
    puts ">"*100
    puts "Strategy: #{all_games_for_player.first.strategy}"
    puts "loses: #{loses}"
    puts "avg_earnings: #{avg}"
    puts "min_earnings: #{all_games_for_player.map(&:balance).min}"
    puts "max_earnings: #{all_games_for_player.map(&:balance).max}"
  end
end

analyse
