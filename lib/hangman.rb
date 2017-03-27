require 'msgpack'

class Hangman
  attr_reader :game_over

  def initialize
    dictionary = init_dictionary
    init_word(dictionary)
    @attempts = 5
    @game_over = false
    @guesses = []
  end

  def init_dictionary
    dictionary = []
    words = File.readlines "5desk.txt"
    words.each do |word|
      word = word.downcase.strip
      dictionary.push word unless word.length < 5 || word.length > 12
    end
    dictionary
  end

  def init_word dictionary
    @word = dictionary.sample
    @word_array = []
    @word.scan(/\w/).each do |letter|
      @word_array.push [letter, false]
    end
  end

  def show_board
    board = ""
    @word_array.each do |letter|
      if letter[1] == true
        board += ("#{letter[0]} ")
      else
        board += "_ "
      end
    end
    puts board.strip
  end
  def take_turn
    puts "#{@attempts} attempts remaining"
    puts "Guess a letter"
    check_guess(gets.chomp.downcase)
    puts ""

  end

  def check_guess(guess)
    if guess == "save"
      save_game
      puts "Game has been save. Goodbye."
      exit
    elsif guess == "load"
      load_game
      return
    end

    puts ""
    if !(guess =~ /[a-z]/)
      puts "Please guess a letter between a and z"
      return
    end

    if @guesses.index(guess) != nil
      puts "You have already guessed #{guess}, please try again"
      return
    end

    result = @word.index(guess)
    if result != nil
      @word_array.map! do |letter|
        if letter[0] == guess
          letter[1] = true
        end
        [letter[0],letter[1]]
      end
    else
      puts "The letter #{guess} was not found. Please try again"
      @attempts -= 1
    end
    @guesses.push (guess)
  end

  def check_board
    if @attempts == 0
      @game_over = true
      puts "Sorry, no more guesses. The word was #{@word}"
    elsif @word_array.all? { |letter| letter[1] }

      @game_over = true
      puts "Congratulations! You have won!!"
    end
  end

  def save_game
    game_file = self.to_msgpack
    File.open('save/save.game','wb') do |file|
      file.write game_file
    end
  end

  def to_msgpack
    MessagePack.dump( {
      :attempts => @attempts,
      :word => @word,
      :word_array => @word_array,
      :guesses => @guesses
    })
  end
  def load_game
    game = File.read ("save/save.game")
    from_msgpack(game)
  end
  def from_msgpack game
    game = MessagePack.unpack game
    @attempts = game ['attempts']
    @word = game['word']
    @word_array = game['word_array']
    @guesses = game['guesses']
  end
end

game = Hangman.new
puts "At any time, type save or load to save your game or load your previously saved game."
puts "Warning: Only one save file can exist at a time"
while game.game_over == false do
  game.show_board
  game.take_turn
  game.check_board
end

game.show_board
