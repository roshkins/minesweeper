class Board

  def initialize(opts)
    opts   = opts.merge( {size: 9, mines: 10} )
    @size  = opts[:size]
    @mines = opts[:mines]
    @board = self.build_board(@size)
  end

  def self.build_board(size)
    board = []
    size.times do
      line = []
      board << line
      size.times do
        line << nil
      end
    end
    board
  end

end

class Tile

  def inititalize(bomb, board)
    @bomb = bomb
    @board = board
    @revealed, @flagged = false, false
    @bomb_count = bomb_count
  end

  def bomb_count
    nil
  end

end