require 'json'


class Player
  attr_accessor :name, :turn, :guessed
  
  def initialize
    @name = 'Player'
    @turn = 0
    @guessed = nil
  end
end


class Hangman
  attr_accessor :secret_word, :player
  
  @@found_letters = []
  
  @@hangman = [
    %q{
       ;---
          |
          |
          |
     ======
    },
    %q{
       ;---
       o  |
          |
          |
      =====
    },     
    %q{
       ;---
       o  | 
       |  |
          |
     ======
    },
    %q{
       ;---
       o  |
      /|  |
          |
     ======    
    },
    %q{
       ;---
       o  |
      /|\ |
          |
     ======
    },
    %q{
       ;---
       o  |
      /|\ |
      /   |
     ======
    },         
    %q{
       ;---
       o  |
      /|\ |
      / \ |
     ======
    }
  ]
  
  def self.found_letters
    @@found_letters
  end
  
  def self.found_letters=(letters)
    @@found_letters = letters
  end
  
  def hangman
    @@hangman
  end
  
  def initialize(secret_word, player)
    @secret_word = secret_word
    @player = player
  end
  
  def modify(letter)
    Hangman.found_letters << letter unless letter.is_a? Regexp
    letters = Hangman.found_letters.join
    copy = secret_word.delete(letters)
    underscored_word = secret_word.gsub(/[#{copy}]/, '_ ')
  rescue RegexpError
    puts secret_word
    puts "Victory! You guessed right!"
    exit(0)
  end
  
  def turn
    @player.turn
  end
  
  def save
    json = JSON.dump({
      :name => player.name,
      :turn => player.turn,
      :guessed => Hangman.found_letters,
      :secret_word => secret_word
    })
    
    File.open("#{player.name}.dat", 'w') do |file|
      file.write(json)
    end
    
    puts "Game saved. Good bye!"
    exit(0)
  end
  
  def play
    until turn == 6
      puts %q{
  1. Save
  2. Exit
  
  Enter your guess (one letter or the whole word)!}

      puts hangman[turn]
      guessed = modify(/\w+/)
      puts guessed
      print '>> '
      guess = gets.chomp.downcase
      
      case
      when guess == '1'
        save
      when guess == '2'
        puts 'Good bye!'
        exit(0)
      when guess == secret_word
        puts "Good job. Well done!"
        exit(0)
      when secret_word.include?(guess) && guess.size == 1
        modify(guess)
      else
        player.turn += 1
      end
      
    end
    puts "You are hanged. What a pity!"
    puts hangman[turn]
  end
end


class Game
  attr_accessor :secret_word, :player
  
  def initialize(player)
    @player = player
  end
  
  def load_game
    data = File.read("#{player.name}.dat")
    data = JSON.load(data)
    player.name = data["name"]
    player.turn = data["turn"]
    Hangman.found_letters = data["guessed"]
    secret_word = data["secret_word"]   
    Hangman.new(secret_word, player).play
  rescue Errno::ENOENT
    puts "Sorry, you don't have any saved game!"
  end
  
  def start
    arr_of_words = File.readlines('5desk.txt')
    random_word = arr_of_words.sample.strip
    random_word = arr_of_words.sample.strip until random_word.size.between?(5, 12)
    secret_word = random_word.downcase
    puts "Hello it's Hangman! Enter your name"
    print '>> '
    name = gets.chomp
    player.name = name unless name.empty?
    
    puts %q{
Please, select:
      
  1. Play
  2. Load game}
     
    print '>> '   
    choice = gets.chomp
    
    if choice == '1'
      Hangman.new(secret_word, player).play
    elsif choice == '2'
      load_game
    else
      puts "Good bye!"
    end
    
  rescue Interrupt
    puts "--> Have a wonderful time! <--"
  end
end



me = Player.new
game = Game.new(me)
game.start
