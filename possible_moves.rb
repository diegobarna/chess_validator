module PossibleMoves
  def straight
    all_moves(%i[u d r l])
  end

  def diagonal
    all_moves(%i[ur ul dr dl])
  end

  def two_up
    %i[u2]
  end

  def two_down
    %i[d2]
  end

  def one_up
    %i[u1]
  end

  def one_down
    %i[d1]
  end

  def one_up_diagonal
    %i[ur1 ul1]
  end

  def one_down_diagonal
    %i[dr1 dl1]
  end

  def one_horizontal
    %i[r1 l1]
  end

  def all_moves(moves)
    moves.product((1..7).to_a).map!{|x| x.join.to_sym}
  end
end
