require 'debugger'
class Board
  attr_reader :board
  def initialize(opts = {})
    opts   = opts.merge( {size: 9, mines: 10} )
    @size  = opts[:size]
    @mines = opts[:mines]
    @board = build_board(@size)
  end

  def [](col, row)
    @board[row][col]
  end

  def to_s
    final_str = ""
    @board.each do |line|
      final_str << "#{line.join(" ")}\n"
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

  def drop_bombs
    # debugger
    @mines.times do
      tile = nil
      loop do #something
        coords = [rand(@size), rand(@size)]
        tile = self[coords[0],coords[1]]
        break if !tile.bomb
      end
      tile.bomb = true
    end
  end

end

class Tile

  attr_reader :revealed, :location
  attr_accessor :bomb

  def initialize(board, location)
    @bomb = false
    @board = board
    @revealed, @flagged = false, false
    @location = location
    # @bomb_count = bomb_count
  end

  def to_s
    return "b" if bomb
    return "*" unless revealed
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
        adj_tiles << @board[rel_x, rel_y] if rel_x >= 0 && rel_y >= 0 && !([rel_x, rel_y] == @location)
      end
    end
    adj_tiles
  end

end

if __FILE__ == $PROGRAM_NAME
  board = Board.new
  # puts board
  x = 2
  y = 1
  # p board[x, y].adjacent_tiles
  p board[8, 4]
  board.drop_bombs

end