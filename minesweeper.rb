require 'debugger'
require 'yaml'
require 'json'
class Board
  attr_reader :board, :size
  attr_accessor :start_time
  attr_writer :total_time
  def initialize(opts = {})
    opts   = {size: 9, mines: 10}.merge( opts )
    @size  = opts[:size]
    @mines = opts[:mines]
    @board = build_board(@size)
    @start_time = Time.new
    @total_time = 0.0
    drop_bombs
  end

  def total_time
    #update total_time
    time_now = Time.new
    @total_time += time_now - @start_time
    @start_time = time_now
    #return total_time
    @total_time
  end

  def [](col, row)
    @board[row][col]
  end

  def to_s
    final_str = ""
    top_border = (0..(@size-1)).to_a * " "
    final_str << "   | #{top_border}\n   | " + "--" * @size + "\n"
    @board.each_with_index do |line, y|
      final_str << " #{y} | #{line.map(&:to_s).join(" ")}\n"
    end
    final_str
  end

  def build_board(size)
    board = []
    size.times do |y|
      line = []
      board << line
      size.times do |x|
        line << Tile.new(self, [x, y])
      end
    end
    board
  end

  def win?
    board.flatten.all? { |tile| tile.revealed || tile.bomb }
  end

  def lose?
    board.flatten.any? { |tile| tile.revealed && tile.bomb }
  end

  def drop_bombs
    @mines.times do
      tile = nil

      begin
        coords = [rand(@size), rand(@size)]
        tile = self[coords[0],coords[1]]
      end while tile.bomb

      # loop do #something
#         coords = [rand(@size), rand(@size)]
#         tile = self[coords[0],coords[1]]
#         break if !tile.bomb
#       end
      tile.bomb = true
    end
  end

end

class Tile

  attr_reader :revealed, :location
  attr_accessor :bomb, :flagged

  def initialize(board, location)
    @bomb = false
    @board = board
    @revealed, @flagged = false, false
    @location = location
    @hint = false
    #@bomb_count = bomb_count
  end

  def to_s
    # return "*" unless revealed
    return @bomb_count if @hint
    return "F" if @flagged
    return "B" if bomb #&& @revealed
    return "_" if @revealed
    return "*"

  end

  def flag
    @flagged = !@flagged
  end

  def reveal
    # debugger
    return true if @revealed
    @bomb_count = bomb_count
    @hint = @bomb_count > 0
    @revealed = true unless (@flagged)

    #recursion
    adjacent_tiles.each { |tile| tile.reveal if @revealed && !@hint }
  end

  def bomb_count
    adjacent_tiles.select { |tile| tile.bomb }.length
  end

  def adjacent_tiles
    adj_tiles = []
    3.times do |x|
      3.times do |y|
        #subtract 1 because we want to change 0 to -1 etc.
        rel_x = @location[0] + x - 1
        rel_y = @location[1] + y - 1
        adj_tiles << @board[rel_x, rel_y] if (rel_x >= 0) && (rel_y >= 0) && !([rel_x, rel_y] == @location) && (rel_x < @board.size) && (rel_y < @board.size)
      end
    end
    adj_tiles
  end

end

class Scoreboard
  def initialize(filename)
    if File.exists?(filename)
      @scores = JSON.parse(File.read(filename))
    else
      File.open(filename, "w") { }
      @scores = []
    end
    @filename = filename
  end
  def add(name, time)
    @scores << {name => time}
  end
  def to_s
    p @scores
    "This is a scoreboard."
  end

  def save
    File.open(@filename, "w") do |f|
      f.puts @scores.to_json
    end
  end
end

class MinesweeperGame

  def initialize(size = 9, mines = 10)
    @board = Board.new({size: size, mines: mines})
    @scoreboard = Scoreboard.new("scoreboard.json")
    start_game
  end

  def start_game
    puts @scoreboard
    load_game
    until @board.win? || @board.lose? || quit?
      do_turn
    end
    show_results
  end

  def save
    @board.total_time
    board_yaml = @board.to_yaml
    print "Please enter a filename: "
    filename = gets.chomp
    File.open("#{filename}.yml", "w") do |f|
      f.puts board_yaml
    end
  end

  def load_game
    print "Please enter a filename to load a saved game or nothing to start a new game: "
    filename = gets.chomp
    @board = YAML.load(File.read(filename)) unless filename.empty?
    @board.start_time = Time.new
  end

  def show_results
    mins = @board.total_time / 60
    puts "That took #{mins} minutes.  What a shame."
    if @board.win?
      puts "You've redeemed yourself as a human being."
    elsif @board.lose?
      puts "To the bowels of hell with you!"
    else
      puts "Goodbye. I will judge you later."
    end
  end

  def coords
    print "Enter X, Y of spot and R or F to reveal or flag.\nAlternatively enter S to Save and Quit: "
    gets.chomp.split(",").map(&:strip)
  end

  def do_turn
    puts @board
    coords2 = coords
    if (coords2 * "").upcase.include? "S"
      save
      quit
      return
    end
    if coords2[2].upcase == "F"
      @board[coords2[0].to_i, coords2[1].to_i].flag
    else
      @board[coords2[0].to_i, coords2[1].to_i].reveal
    end
  end

  def quit
    @quit = true
  end

  def quit?
    @quit
  end
end


if __FILE__ == $PROGRAM_NAME
  # board = Board.new
 #  puts board
 #  x = 8
 #  y = 8
 #  p board[x, y].reveal
 #
 #
 #  p board
  # p board[x, y].adjacent_tiles

  #game = MinesweeperGame.new(9, 1)

  scoreboard = Scoreboard.new("test_scores.json")
  puts scoreboard
  scoreboard.add("Rashi", "-14 seconds")
  puts scoreboard

end