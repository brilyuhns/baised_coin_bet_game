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
      current_toss = toss
      @outcomes << current_toss
      @players.each do |player|
        calculate_outcome(player, current_toss)
      end
      update_valid_players
    end
  end

  def calculate_outcome(player, toss)
    bet = player.next_bet(@outcomes)
    if bet.choice == toss
      # puts "Player: #{player}; Bet: #{bet}; toss: #{toss}; win"
      player.add_to_balance(bet.amount)
    else
      # puts "Player: #{player}; Bet: #{bet}; toss: #{toss}; lose"
      player.deduct_from_balance(bet.amount)
    end
  end

  def update_valid_players
    @players.reject!(&:is_bankrupt?)
  end
end

class Player
  def initialize strategy
    @strategy = strategy.new
    @balance = 25
    @bets = []
  end

  def balance
    @balance
  end

  def next_bet(outcomes)
    @bets << @strategy.next_bet(@bets, outcomes)
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
    str = ["strategy: #{@strategy.class.name}"]
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
    choice = Rational(bets.count(1)/bets.count) > 0.6 ? 1 : 0
    Bet.new(choice, 5)
  end
end


def run_game
    players = [Player.new(Strategy1)]
    game = MultiplayerGame.new(players)
    game.play
    puts players.map(&:to_s)
end

run_game
