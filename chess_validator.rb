require 'pry'
require_relative 'possible_moves'

class Validator
  def initialize(board, moves)
    @moves = parse_moves(moves)
    @board = Board.new(board)
    @results = []
  end

  def parse_moves(moves)
    moves
  end

  def write_results(file="results.txt")
    IO.write(file, @results.join("\n"))
  end

  def validate
    @moves.each do |move|
      move = Move.new(move, @board)
      @results << move.is_legal?
    end
    p @results
  end
end

# Start Move class

class Move
  def initialize(move, board)
    @board = board
    @move = move
    @piece_to_move = @board.read_cell(@move[0])
  end

  def is_legal?
    case @piece_to_move[:type]
    when "R"
      piece = Rook.new(@piece_to_move[:color])
    when "N"
      piece = Knight.new(@piece_to_move[:color])
    when "B"
      piece = Bishop.new(@piece_to_move[:color])
    when "Q"
      piece = Queen.new(@piece_to_move[:color])
    when "K"
      piece = King.new(@piece_to_move[:color])
    when "P"
      piece = Pawn.new(@piece_to_move[:color])
    else
      return false
    end

    if piece.is_valid?(@move[0], dir_and_range, @board.read_cell(@move[1])) && @board.clear_path(@move[0], dir_and_range)
      return true
    else
      return false
    end
  end

  def dir_and_range
    direction = ""
    vertical_move = @move[1][0] - @move[0][0] 
    horizontal_move = @move[1][1] - @move[0][1]

    if (vertical_move.abs == 1 && horizontal_move == 2) || (vertical_move.abs == 2 && horizontal_move.abs == 1)
      return :j1
    end

    if horizontal_move == 0
      range = vertical_move
    elsif vertical_move == 0
      range = horizontal_move
    elsif horizontal_move == vertical_move
      range = horizontal_move
    else
      return false
    end

    case vertical_move
    when (-7...0)
      direction += "u"
    when (1..7)
      direction += "d"
    end

    case horizontal_move
    when (-7...0)
      direction += "l"
    when (1..7)
      direction += "r"
    end
    direction = direction + range.abs.to_s
    direction.to_sym
  end
end

# Start Board class

class Board
  def initialize(board)
    @board = parse_board(board)
    @results = []
  end

  def parse_board(board)
    board
  end

  def read_cell(pos)
    cell = @board[pos[0]][pos[1]]
    if cell
      type = /[RNBQKP]/.match(cell)[0]
      color = /[wb]/.match(cell)[0]
      {type: type, color: color}
    else
      :nil
    end
  end

  def clear_path(origin, dir_and_range)
    steps = []
    dir = dir_and_range.to_s.chars
    range = dir.pop.to_i - 1
    dir = dir.to_s
    if range != 0
      case dir
      when "j"
        return true
      when "u"
        range.times do
          steps << [origin[0] - 1, origin[1]]
        end
      when "d"
        range.times do
          steps << [origin[0] + 1, origin[1]]
        end
      when "r"
        range.times do
          steps << [origin[0], origin[1] + 1]
        end
      when "l"
        range.times do
          steps << [origin[0], origin[1] - 1]
        end
      when "ur"
        range.times do
          steps << [origin[0] - 1, origin[1] + 1]
        end
      when "ul"
        range.times do
          steps << [origin[0] - 1, origin[1] - 1]
        end
      when "dr"
        range.times do
          steps << [origin[0] + 1, origin[1] + 1]
        end
      when "dl"
        range.times do
          steps << [origin[0] + 1, origin[1] - 1]
        end
      end
    else
      return true
    end

    steps.each do |step|
      if step != :nil
        next
      else
        return false
      end
    end
    return true
  end
end

# Start pieces classess

class Piece
include PossibleMoves

  def initialize(color)
    @color = color
    @valid_moves = []
  end

  def is_valid?(origin, dir_and_range, dest_piece)
    if dest_piece != :nil
      dest_piece = dest_piece[:color]
    else
      dest_piece = false
    end
    if @valid_moves.include?(dir_and_range) && dest_piece != @color
      true
    else
      false
    end
  end
end

class Rook < Piece
  def initialize(color)
    super
    @valid_moves = straight + two_down + two_up + one_horizontal + one_up + one_down
  end
end

class Knight < Piece
  def initialize(color)
    @valid_moves = %i[:j1]
  end
end

class Bishop < Piece
  def initialize(color)
    @valid_moves = diagonal
  end
end

class Queen < Piece
  def initialize(color)
    @valid_moves = straight + diagonal
  end
end

class King < Piece
  def initialize(color)
    @valid_moves = one_horizontal + one_up_diagonal + one_down_diagonal + one_up + one_down
  end
end

class Pawn < Piece
  def initialize(color)
    if @color == "w"
      @valid_moves += two_up
      if @dest_piece == "b"
        @valid_moves += one_up_diagonal
      end
    elsif @color == "b"
      @valid_moves += two_down
      if @dest_piece == "w"
        @valid_moves += one_down_diagonal
      end
    end
  end
end

board = [ 
    [:bR, nil, nil, nil, nil, nil, nil, nil], # a8 = [0][0] .. h8 = [0][7]
    [nil, nil, nil, nil, nil, nil, nil, nil], # a7 = [1][0] .. h7 = [1][7]
    [nil, nil, nil, nil, nil, nil, nil, nil],
    [nil, nil, nil, nil, nil, nil, nil, nil], 
    [nil, nil, nil, nil, nil, nil, nil, nil],
    [nil, nil, nil, nil, nil, nil, nil, nil],
    [nil, nil, nil, nil, nil, nil, nil, nil], # a2 = [6][0] .. h2 = [6][7]
    [:wR, :wN, nil, nil, nil, nil, nil, nil]  # a1 = [7][0] .. h1 = [7][7]
  ]

# moves = [[:a1,:a2], [:a8,:a1], [:a1,:b1]]
moves = [ 
  [[7,0],[6,0]], # => true
  [[7,0],[0,0]], # => true
  [[7,0],[7,1]], # => false
  [[0,0],[7,0]], # => true
  [[7,1],[7,0]]  # => false
]

validation = Validator.new(board, moves)
validation.validate

