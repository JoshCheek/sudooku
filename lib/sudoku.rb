class Sudoku
  InvalidBoard = Class.new RuntimeError

  def self.from_string(board_string)
    board = board_string.lines.map do |line|
      chars = line.chars
      chars.pop
      validate! chars
    end
    board.transpose.each { |col| validate! col }
    board.each_slice(3) do |rows|
      rows.map { |row| row.each_slice(3).to_a }
          .transpose.each { |chunks| validate! chunks.flatten }
    end
    new(board)
  end

  def self.validate!(row)
    row.reject { |c| c == '_' }
       .group_by(&:itself)
       .map(&:last)
       .map(&:length)
       .reject { |count| count == 1 }
       .each { raise InvalidBoard }
    invalid_chars = row.reject { |c| c =~ /[_1-9]/ }
    if invalid_chars.any?
      raise InvalidBoard, "#{invalid_chars.inspect} are not valid board characters"
    end
    row
  end


  attr_accessor :board

  def initialize(board)
    self.board = board
  end
end
