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
      expect(sudoku.at 0, 0).to eq 5
      expect(sudoku.at 1, 0).to eq 6
    end
  end

  describe 'accessing' do
    let(:sudoku) { Sudoku.from_string <<~SUDOKU }
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

    it 'gets the rows' do
      expect(sudoku.row 0).to eq [5, 3, 4, 6, 7, 8, 9, 1, 2]
      expect(sudoku.row 1).to eq [6, 7, 2, 1, 9, 5, 3, 4, 8]
      expect(sudoku.row 2).to eq [1, 9, 8, 3, 4, 2, 5, 6, 7]
      expect(sudoku.row 3).to eq [8, 5, 9, 7, 6, 1, 4, 2, 3]
      expect(sudoku.row 4).to eq [4, 2, 6, 8, 5, 3, 7, 9, 1]
      expect(sudoku.row 5).to eq [7, 1, 3, 9, 2, 4, 8, 5, 6]
      expect(sudoku.row 6).to eq [9, 6, 1, 5, 3, 7, 2, 8, 4]
      expect(sudoku.row 7).to eq [2, 8, 7, 4, 1, 9, 6, 3, 5]
      expect(sudoku.row 8).to eq [3, 4, 5, 2, 8, 6, 1, 7, 9]
    end

    it 'gets the columns' do
      expect(sudoku.col 0).to eq [5, 6, 1, 8, 4, 7, 9, 2, 3]
      expect(sudoku.col 1).to eq [3, 7, 9, 5, 2, 1, 6, 8, 4]
      expect(sudoku.col 2).to eq [4, 2, 8, 9, 6, 3, 1, 7, 5]
      expect(sudoku.col 3).to eq [6, 1, 3, 7, 8, 9, 5, 4, 2]
      expect(sudoku.col 4).to eq [7, 9, 4, 6, 5, 2, 3, 1, 8]
      expect(sudoku.col 5).to eq [8, 5, 2, 1, 3, 4, 7, 9, 6]
      expect(sudoku.col 6).to eq [9, 3, 5, 4, 7, 8, 2, 6, 1]
      expect(sudoku.col 7).to eq [1, 4, 6, 2, 9, 5, 8, 3, 7]
      expect(sudoku.col 8).to eq [2, 8, 7, 3, 1, 6, 4, 5, 9]
    end

    it 'gets the blocks' do
      expect(sudoku.block 2, 0).to eq [5, 3, 4, 6, 7, 2, 1, 9, 8]
      expect(sudoku.block 3, 0).to eq [8, 5, 9, 4, 2, 6, 7, 1, 3]
      expect(sudoku.block 5, 0).to eq [8, 5, 9, 4, 2, 6, 7, 1, 3]
      expect(sudoku.block 6, 0).to eq [9, 6, 1, 2, 8, 7, 3, 4, 5]

      expect(sudoku.block 0, 2).to eq [5, 3, 4, 6, 7, 2, 1, 9, 8]
      expect(sudoku.block 0, 3).to eq [6, 7, 8, 1, 9, 5, 3, 4, 2]
      expect(sudoku.block 0, 5).to eq [6, 7, 8, 1, 9, 5, 3, 4, 2]
      expect(sudoku.block 0, 6).to eq [9, 1, 2, 3, 4, 8, 5, 6, 7]
    end

    it 'sets a value into the correct row/col/block' do
      expect(sudoku.row   4).to    eq [4, 2, 6, 8, 5, 3, 7, 9, 1]
      expect(sudoku.col   4).to    eq [7, 9, 4, 6, 5, 2, 3, 1, 8]
      expect(sudoku.block 4, 4).to eq [7, 6, 1, 8, 5, 3, 9, 2, 4]
      sudoku.set 3, 3, 1
      sudoku.set 3, 4, 2
      sudoku.set 3, 5, 3
      sudoku.set 4, 3, 4
      sudoku.set 4, 4, 5
      sudoku.set 4, 5, 6
      sudoku.set 5, 3, 7
      sudoku.set 5, 4, 8
      sudoku.set 5, 5, 9
      expect(sudoku.row   4).to    eq [4, 2, 6, 4, 5, 6, 7, 9, 1]
      expect(sudoku.col   4).to    eq [7, 9, 4, 2, 5, 8, 3, 1, 8]
      expect(sudoku.block 4, 4).to eq [1, 2, 3, 4, 5, 6, 7, 8, 9]
    end
  end

  describe 'solving' do
    def assert_solves(board, solution)
      sudoku = Sudoku.from_string(board)
      expect(sudoku.solve!).to eq true
      expect(sudoku.to_s).to eq Sudoku.from_string(solution).to_s
    end

    it 'can solve by a missing piece horizontally' do
      assert_solves <<~SUDOKU, <<~SUDOKU
        _34678912
        _72195348
        _98342567
        _59761423
        _26853791
        _13924856
        _61537284
        _87419635
        _45286179
      SUDOKU
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
    end

    it 'can solve by a missing piece vertically' do
      assert_solves <<~SUDOKU, <<~SUDOKU
       _________
       672195348
       198342567
       859761423
       426853791
       713924856
       961537284
       287419635
       345286179
      SUDOKU
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
    end

    it 'can solve by a missing piece in the block' do
      sudoku = assert_solves <<~SUDOKU, <<~SUDOKU
        _34 _78 _12
        672 195 348
        198 342 567

        _59 _61 _23
        426 853 791
        713 924 856

        _61 _37 _84
        287 419 635
        345 286 179
      SUDOKU
        534 678 912
        672 195 348
        198 342 567

        859 761 423
        426 853 791
        713 924 856

        961 537 284
        287 419 635
        345 286 179
      SUDOKU
    end

    it 'can solve one with a bunch of spots knocked out' do
      sudoku = assert_solves <<~SUDOKU, <<~SUDOKU
        53_678_12
        6_21953_8
        1983_256_
        859_614_3
        4268_3791
        7_392_856
        _615_7284
        _87419_35
        3_528_179
      SUDOKU
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
    end

    # too inefficient :(
    xit 'can solve a practice board I found on the internet' do
      sudoku = assert_solves <<~SUDOKU, <<~SUDOKU
        53__7____
        6__195___
        _98____6_
        8___6___3
        4__8_3__1
        7___2___6
        _6____28_
        ___419__5
        ____8__79
      SUDOKU
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
    end

    xit 'can solve the hard problem given in the video' do
      sudoku = Sudoku.from_string <<~SUDOKU
        8__ ___ ___
        __3 6__ ___
        _7_ _9_ 2__

        _5_ __7 ___
        ___ _45 7__
        ___ 1__ _3_

        __1 ___ _68
        __8 5__ _1_
        _9_ ___ 4__
      SUDOKU
      require "pry"
      binding.pry
      expect(sudoku.solve!).to eq true
    end
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
