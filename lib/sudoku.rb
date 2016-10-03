class Sudoku
  InvalidBoard = Class.new RuntimeError

  def self.from_string(board_string)
    board_string = board_string.gsub(" ", "").gsub("\n\n", "\n")
    invalid_chars = board_string.gsub(/[_1-9\n]/, '').chars.uniq
    invalid_chars.any? and
      raise InvalidBoard, "#{invalid_chars.inspect} are not valid board characters"

    board = board_string.lines.map do |line|
      chars = line.chars.tap(&:pop)
      chars.map { |char| char == '_' ? nil : char.to_i }
    end

    sudoku = new board
    sudoku.rows.each   { |row| validate! row }
    sudoku.cols.each   { |col| validate! col }
    sudoku.blocks.each { |blk| validate! blk }

    sudoku
  end

  def self.validate!(row)
    row.reject { |c| c == nil }
       .group_by(&:itself)
       .map(&:last)
       .map(&:length)
       .reject { |count| count == 1 }
       .each { raise InvalidBoard }
  end

  attr_accessor :rows, :cols, :blocks

  def initialize(rows)
    self.rows   = rows
    self.cols   = rows.transpose
    self.blocks = rows.each_slice(3).flat_map do |slice|
      slice.map do |line|
        line.each_slice(3).to_a
      end.transpose.map(&:flatten)
    end
  end

  def solve!
    return true if solved?
    # puts "\n#{self}"
    each_unsolved do |y, x|
      potentials = potentials_at(y, x)
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
    row(y)[x] = col(x)[y] = block(y, x)[y%3*3+x%3] = value
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
    blocks[y/3*3+x/3]
  end

  def to_s
    rows.map do |row|
      row.map { |val| val ? val : " " }.join
    end.join("\n")
  end
end
