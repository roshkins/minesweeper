require 'debugger'
require 'yaml'

class Board
  attr_reader :board, :size
  def initialize(opts = {})
    opts   = {size: 9, mines: 10}.merge( opts )
    @size  = opts[:size]
    @mines = opts[:mines]
    @board = build_board(@size)
    drop_bombs
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

class MinesweeperUI

  def initialize(size = 9, mines = 10)
    @board = Board.new({size: size, mines: mines})
    start_game
  end

  def start_game
    load_game
    start_time = Time.new
    until @board.win? || @board.lose? || quit?
      do_turn
    end
    end_time = Time.new
    total_time = end_time - start_time
    show_results(total_time)
  end

  def load_game
    print "Please enter a filename to load a saved game or nothing to start a new game: "
    filename = gets.chomp
    @board = YAML.load(File.read(filename)) unless filename.empty?
  end

  def show_results(total_time)
    mins = total_time.to_f / 60.0
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

  def save
    board_yaml = @board.to_yaml
    print "Please enter a filename: "
    filename = gets.chomp
    File.open("#{filename}.yml", "w") do |f|
      f.puts board_yaml
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

  game = MinesweeperUI.new(9, 1)

end