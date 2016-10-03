class Sudoku
  InvalidBoard = Class.new RuntimeError

  def self.from_string(board_string)
    board_string = board_string.gsub(" ", "").gsub("\n\n", "\n")
    invalid_chars = board_string.gsub(/[_1-9\n]/, '').chars.uniq
    if invalid_chars.any?
      raise InvalidBoard, "#{invalid_chars.inspect} are not valid board characters"
    end
    board = board_string.lines.map do |line|
      line.chars.tap(&:pop).tap do |chars|
        validate! chars.map! { |char|
          char == '_' ? nil : char.to_i
        }
      end
    end
    board.transpose.each { |col| validate! col }
    board.each_slice(3) do |rows|
      rows.map { |row| row.each_slice(3).to_a }
          .transpose.map(&:flatten)
          .each { |chunk| validate! chunk }
    end
    new(board)
  end

  def self.validate!(row)
    row.reject { |c| c == nil }
       .group_by(&:itself)
       .map(&:last)
       .map(&:length)
       .reject { |count| count == 1 }
       .each { raise InvalidBoard }
    row
  end


  def initialize(rows)
    self.rows   = rows
    self.cols   = rows.transpose
    self.blocks = rows.each_slice(3).map do |slice|
      slice.map do |line|
        line.each_slice(3).to_a
      end.transpose.map(&:flatten)
    end
  end

  def solve!
    return true if solved?
    # puts "\n#{self}"
    # if STDIN.gets == "y\n"
    #   require "pry"
    #   binding.pry
    # end
    each_unsolved do |y, x|
      potentials = potentials_at(y, x)
      # p [y, x] => potentials
      return false if potentials.empty?
      potentials.each do |potential|
        set y, x, potential
        return true if solve!
      end
      set y, x, nil
    end
    solved?
  end

  def at(y, x)
    rows[y][x]
  end

  def set(y, x, value)
    rows[y][x] = value
  end

  AVAILABLE = [*1..9].freeze
  def potentials_at(y, x)
    values = AVAILABLE.dup
    row(y).each      { |val| values.delete val }
    col(x).each      { |val| values.delete val }
    block(y, x).each { |val| values.delete val }
    values
  end

  def each_unsolved
    rows.each_with_index do |row, y|
      row.each_with_index do |value, x|
        yield y, x unless value
      end
    end
  end

  def solved?
    rows.all? { |row| row.all? &:itself }
  end

  def row(y)
    rows[y]
  end

  def col(x)
    cols[x]
  end

  def block(y, x)
    blocks[y/3][x/3]
  end

  def to_s
    rows.map do |row|
      row.map { |val| val ? val : " " }.join
    end.join("\n")
  end

  private

  attr_accessor :rows, :cols, :blocks
end
