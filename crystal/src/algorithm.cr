module Algorithm
  module Helper
    def self.create_matrix(subject_length, query_length)
      Array.new((subject_length + 1) * (query_length + 1), 0)
    end

    def self.get_matrix(matrix, column_length, i, j)
      matrix[(i * column_length) + j]
    end

    def self.set_matrix(matrix, column_length, i, j, value)
      matrix[(i * column_length) + j] = value
    end

    def self.calculate_matrix_score(subject : String, query : String, matrix, match_bonus, mismatch_penalty, gap_penalty)
      subject_length = subject.size
      query_length = query.size
      column_length = query_length + 1

      (1..subject_length).each do |i|
        (1..query_length).each do |j|
          diagonal = get_matrix(matrix, column_length, i - 1, j - 1)
          up = get_matrix(matrix, column_length, i - 1, j)
          left = get_matrix(matrix, column_length, i, j - 1)

          matching = 0
          if subject[i - 1] == query[j - 1]
            matching = diagonal + match_bonus
          else
            matching = diagonal - mismatch_penalty
          end

          upward_gap = up - gap_penalty
          leftward_gap = left - gap_penalty

          set_matrix(matrix, column_length, i, j, [matching, upward_gap, leftward_gap, 0].max)
        end
      end
    end

    def self.backtrack_alignment(subject : String, query : String, matrix, match_bonus, mismatch_penalty, gap_penalty)
      subject_length = subject.size
      query_length = query.size
      column_width = query_length + 1

      max_score_index = matrix.index!(matrix.max)

      subject_line = IO::Memory.new([subject_length, query_length].max)
      query_line = IO::Memory.new([subject_length, query_length].max)

      current_i = (max_score_index / column_width).to_i
      current_j = max_score_index % column_width

      while current_i > 0 && current_j > 0
        cur = get_matrix(matrix, column_width, current_i, current_j)

        diagonal = get_matrix(matrix, column_width, current_i - 1, current_j - 1)
        diagonal_match = diagonal + match_bonus
        diagonal_mismatch = diagonal - mismatch_penalty

        up = get_matrix(matrix, column_width, current_i - 1, current_j)
        up_gap = up - gap_penalty

        left = get_matrix(matrix, column_width, current_i, current_j - 1)
        left_gap = left - gap_penalty

        if cur == 0
          # puts "Reaced end"
          break
        elsif cur == diagonal_match && subject[current_i - 1] == query[current_j - 1]
          subject_line << subject[current_i - 1]
          query_line << query[current_j - 1]
          current_i -= 1
          current_j -= 1
          # puts "Diagonal match, top #{subject}, left #{query_line}"
        elsif cur == diagonal_mismatch && subject[current_i - 1] != query[current_j - 1]
          subject_line << subject[current_i - 1]
          query_line << query[current_j - 1]
          current_i -= 1
          current_j -= 1
          # puts "Diagonal mismatch, top #{subject}, left #{query_line}"
        elsif cur == up_gap
          subject_line << subject[current_i - 1]
          query_line << "-"
          current_i -= 1
          # puts "Upward gap, top #{subject}, left #{query_line}"
        elsif cur == left_gap
          subject_line << "-"
          query_line << query[current_j - 1]
          current_j -= 1
          # puts "Leftward gap, top #{subject}, left #{query_line}"
        else
          # puts "Reached non-matching"
          break
        end
      end

      subject_line_str = subject_line.to_s.reverse
      query_line_str = query_line.to_s.reverse

      {subject_line_str, query_line_str}
    end
  end

  def self.smith_waterman(subject : String, query : String, match_bonus, mismatch_penalty, gap_penalty)
    subject_length = subject.size
    query_length = query.size

    matrix = Helper.create_matrix(subject_length, query_length)

    Helper.calculate_matrix_score(subject, query, matrix, match_bonus, mismatch_penalty, gap_penalty)

    Helper.backtrack_alignment(subject, query, matrix, match_bonus, mismatch_penalty, gap_penalty)
  end
end
