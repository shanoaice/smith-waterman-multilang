require "./algorithm.cr"
require "option_parser"

module SmithWaterman
  VERSION = "0.1.0"

  subject : String? = nil
  query : String? = nil
  match_bonus = 2
  mismatch_penalty = 1
  gap_penalty = 2

  OptionParser.parse do |parser|
    parser.banner = "Simple Smith-Waterman Algorithm"

    parser.on("-h", "--help", "Show this help") do
      puts parser
      exit
    end

    parser.on "-s", "--subject=FILE", "Subject sequence file" do |filename|
      subject_path = Path.new(filename)
      subject_file = File.new(filename)

      if !File.exists?(subject_path)
        STDERR.puts "subject sequence file does not exist"
        exit 1
      end
      subject = subject_file.gets.try(&.strip)
      # puts "Subject sequence: #{subject}"
    end

    parser.on "-q", "--query=FILE", "Query sequence file" do |filename|
      query_path = Path.new(filename)
      query_file = File.new(filename)

      if !File.exists?(query_path)
        STDERR.puts "query sequence file does not exist"
        exit 1
      end
      query = query_file.gets.try(&.strip)
      # puts "Query sequence: #{query}"
    end

    parser.on "-m", "--match=BONUS", "Match bonus" { |bonus| match_bonus = bonus.to_i }
    parser.on "-M", "--mismatch=PENALTY", "Mismatch penalty" { |penalty| mismatch_penalty = penalty.to_i }
    parser.on "-g", "--gap=PENALTY", "Gap penalty" { |penalty| gap_penalty = penalty.to_i }

    parser.missing_option do |option_flag|
      STDERR.puts "ERROR: #{option_flag} is missing a value."
      STDERR.puts parser
      exit 1
    end

    parser.invalid_option do |option_flag|
      STDERR.puts "ERROR: #{option_flag} is invalid."
      STDERR.puts parser
      exit 1
    end
  end

  unless subject
    STDERR.puts "--subject=FILE is required"
    exit 1
  end

  unless query
    STDERR.puts "--query=FILE is required"
    exit 1
  end

  subject_s = subject.not_nil!
  query_s = query.not_nil!

  top_sequence, side_sequence = Algorithm.smith_waterman(subject_s, query_s, match_bonus, mismatch_penalty, gap_penalty)

  puts top_sequence
  puts side_sequence
end
