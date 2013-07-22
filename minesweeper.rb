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
    @board.each do |line|
      puts line.join(" ")
    end
  end

  def build_board(size)
    board = []
    size.times do |y|
      line = []
      board << line
      size.times do |x|
        line << Tile.new(false, self, [x, y])
      end
    end
    board
  end

end

class Tile

  attr_reader :revealed

  def initialize(bomb, board, location)
    @bomb = bomb
    @board = board
    @revealed, @flagged = false, false
    @bomb_count = bomb_count
    @location = location
  end

  def to_s
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
  #p board
  x = 2
  y = 1
  p board[x, y].adjacent_tiles

end