class Board

  def initialize(opts = {})
    opts   = opts.merge( {size: 9, mines: 10} )
    @size  = opts[:size]
    @mines = opts[:mines]
    @board = self.build_board(@size)
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
    nil
  end

  def adjacent_tiles
    adj_tiles = []
    3.times do |x|
      3.times do |y|
        adj_tiles << @board[x-1, y-1]
      end
    end
  end

end

if __FILE__ == $PROGRAM_NAME
  board = Board.new
  puts board

end