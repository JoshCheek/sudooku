require 'sudoku'

RSpec.describe 'sudoku' do
  let(:board) { <<~SUDOKU }
    534678912
    672195348
    198342567
    859761423
    426853791
    713924856
    961537284
    287419635
    345286179
  SUDOKU

  def assert_valid(board)
    expect { Sudoku.from_string board }.to_not raise_error
  end

  def assert_invalid(board)
    expect { Sudoku.from_string board }.to raise_error Sudoku::InvalidBoard
  end

  describe 'validation' do
    before { assert_valid board }

    it 'validates that the same number doesn\'t show up multiple times on the same horizontal' do
      expect(board[10]).to eq '6'
      board[0], board[10] = board[10], board[0]
      assert_invalid board
    end

    it 'validates that the same number doesn\'t show up multiple times on the same vertical' do
      board[0], board[1] = board[1], board[0]
      assert_invalid board
    end

    it 'validates that the same number doesn\'t show up multiple times on the same block'  do
      # We swap within the rows, so the rows are still fine
      # And this pair is special b/c the two row swaps keep the verticals fine, too
      # So it is only the block that becomes invalid
      expect(board.chars.values_at 2, 6, 32, 36).to eq ['4', '9', '9', '4']
      board[2],  board[6]  = board[6],  board[2]
      board[32], board[36] = board[36], board[32]
      assert_invalid board
    end

    it 'validates that all digits are 1-9, and underscores, separated by newlines, ignoring spaces and blank lines' do
      b = board.dup
      b[0] = '0'
      assert_invalid b

      b = board.dup
      b[0] = '_'
      assert_valid b

      b = " #{board}"
      b[10, 0] = "\n"
      assert_valid board
      sudoku = Sudoku.from_string(b)
      expect(sudoku.at 0, 0).to eq '5'
      expect(sudoku.at 1, 0).to eq '6'
    end
  end

  describe 'solving' do
    it 'can solve by a missing piece horizontally' do
      assert_solves <<~SUDOKU, 5, y: 0, x: 0
        _34678912
        _________
        _________
        _________
        _________
        _________
        _________
        _________
        _________
      SUDOKU
    end

    it 'can solve by a missing piece vertically' do
      assert_solves <<~SUDOKU, 5, y: 0, x: 0
       _________
       6________
       1________
       8________
       4________
       7________
       9________
       2________
       3________
     SUDOKU
    end

    it 'can solve by a missing piece in the block' do
      assert_solves <<~SUDOKU, 5, y: 0, x: 0
        _34______
        672______
        198______
        _________
        _________
        _________
        _________
        _________
        _________
      SUDOKU
    end

    it 'can solve by a conjunction of missing pieces horizontally and vertically'
    it 'can solve by a conjunction of missing pieces horizontally by block'
    it 'can solve by a conjunction of missing pieces vertically by block'
    it 'can solve by a conjunction of missing pieces horizontally, vertically, and by block'
  end
end

# 534678912
# 672195348
# 198342567
# 859761423
# 426853791
# 713924856
# 961537284
# 287419635
# 345286179
