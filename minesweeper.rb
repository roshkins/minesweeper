require 'debugger'
class Board
  attr_reader :board, :size
  def initialize(opts = {})
    opts   = opts.merge( {size: 9, mines: 10} )
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
    @board.each do |line|
      final_str << "#{line.map(&:to_s).join(" ")}\n"
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
  attr_accessor :bomb

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
    p 'in to_s' if @revealed
    return @bomb_count if @hint
    return "F" if @flagged
    return "B" if bomb #&& @revealed
    return "_" if @revealed
    return "*"

  end

  def reveal
    # debugger
    @bomb_count = bomb_count
    @revealed = true unless @flagged || @bomb_count > 0
    @hint = @bomb_count > 0
    #recursion
    adjacent_tiles.each { |tile| tile.reveal } if @revealed
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
        adj_tiles << @board[rel_x, rel_y] if rel_x >= 0 && rel_y >= 0 && !([rel_x, rel_y] == @location) && rel_x < @board.size && rel_y < @board.size
      end
    end
    adj_tiles
  end

end

if __FILE__ == $PROGRAM_NAME
  board = Board.new
  puts board
  x = 2
  y = 1
  board[x, y].reveal
  puts
  puts board
  # p board[x, y].adjacent_tiles


end