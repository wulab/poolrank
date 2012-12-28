#!/usr/bin/env ruby
require 'yaml'

DATAFILE = __FILE__.sub(File.extname(__FILE__), ".yml")

def load_data()
  YAML.load_file(DATAFILE)
end

def save_data(data)
  File.open(DATAFILE, "w") do |file|
    YAML.dump(data, file)
  end
end

def generate_data_file()
  File.open(DATAFILE, "w") do |file|
    file.write(<<-EOF)
# PoolRank initial data file.
# Please keep player names under six characters.
---
company: dummy
players:
- foo
- bar
    EOF
  end
end

def generate_matches()
  data = load_data()
  data["matches"] = []
  data["players"].combination(2).each do |player1, player2|
    data["matches"] << [player1, player2, 0].join(",")
  end
  save_data(data)
end

def matches_generated?()
  data = load_data()
  !data["matches"].nil?
end

def extract_matches(data)
  matches = []
  data["matches"].each do |match|
    player1, player2, result = match.chomp.split(",")
    matches << [player1, player2, result.to_i]
  end
  matches
end

########################################

def initialize_stats()
  stats = {}
  data = load_data()
  data["players"].each do |player|
    stats[player] = Hash.new(0)
  end
  stats
end

def calculate_stats(matches)
  stats = initialize_stats()
  matches.each do |player1, player2, result|
    unless result.zero?
      if result > 0
        winner, loser = player1, player2
      else
        winner, loser = player2, player1
      end

      stats[winner]["wins"] += 1
      stats[winner]["points"] += 1
      stats[loser]["loses"] += 1
      stats[loser]["points"] -= 1
    end
  end
  stats
end

def assign_rankings(stats)
  stats.sort_by do |player, player_stats|
    [-player_stats["points"], -player_stats["wins"], player]
  end
end

def disp(text=nil)
  indent = "  "
  text = (indent << text).upcase unless text.nil?
  puts text
end

########################################

def current_standings()
  data = load_data()
  matches = extract_matches(data)
  rankings = assign_rankings(calculate_stats(matches))

  disp
  disp "#{data["company"]} POOL TOURNAMENT".center(38)
  disp "CURRENT STANDINGS".center(38)
  disp
  disp " POS | PLAYER | WINS | LOSES | POINTS "
  disp "-----+--------+------+-------+--------"
  rankings.each_with_index do |(player, player_stats), index|
    wins, loses, points = player_stats.values_at("wins", "loses", "points")
    template = " %3s | %-6s | %4s | %5s | %6s "
    disp template % [index+1, player, wins, loses, points]
  end
  disp
end

def match_results()
  data = load_data()
  matches = extract_matches(data)
  unplayed = matches.select { |_, _, result| !result.zero? }

  disp
  disp "#{data["company"]} POOL TOURNAMENT".center(38)
  disp "MATCH RESULTS".center(38)
  disp
  disp " NO. | MATCH                 | WINNER "
  disp "-----+-----------------------+--------"
  unplayed.each_with_index do |(player1, player2, result), index|
    versus = [player1, player2].join(" vs ")
    winner = result > 0 ? player1 : player2
    disp " %3s | %-21s | %-6s " % [index+1, versus, winner]
  end
  disp
end

def remaining_matches()
  data = load_data()
  matches = extract_matches(data)
  unplayed = matches.select { |_, _, result| result.zero? }

  disp
  disp "#{data["company"]} POOL TOURNAMENT".center(38)
  disp "REMAINING MATCHES".center(38)
  disp
  disp " NO. | MATCH                          "
  disp "-----+--------------------------------"
  unplayed.each_with_index do |(player1, player2, _), index|
    versus = [player1, player2].join(" vs ")
    disp " %3s | %-21s" % [index+1, versus]
  end
  disp
end

def summary()
  current_standings()
  match_results()
  remaining_matches()
end

########################################

def usage()
  puts(<<-EOF)
Usage: ruby #{File.basename(__FILE__)} <command>

Available commands are:
  init        Create an initial data file, overwrite existing one
  new         Generate new tournament matches from data file
  show        Display tournament summary
  standings   Display current standings table
  results     Display past match results
  matches     Display remaining unplayed matches

  EOF
end

def error(message)
  $stderr.puts(message)
  exit(false)
end

def check_data_file()
  unless File.exist?(DATAFILE)
    error "#{File.basename(__FILE__)}: Data file does not exist. " +
          "See 'ruby #{File.basename(__FILE__)} help'."
  end
end

def check_requirements()
  check_data_file()
  unless matches_generated?()
    error "#{File.basename(__FILE__)}: No matches in data file. " +
          "See 'ruby #{File.basename(__FILE__)} help'."
  end
end

if __FILE__ == $0
  case ARGV[0]
  when nil, "help"
    usage()
  when "init"
    generate_data_file()
  when "new"
    check_data_file()
    generate_matches()
  when "show"
    check_requirements()
    summary()
  when "standings"
    check_requirements()
    current_standings()
  when "results"
    check_requirements()
    match_results()
  when "matches"
    check_requirements()
    remaining_matches()
  else
    error("#{File.basename(__FILE__)}: '#{ARGV[0]}' is not a valid command.")
  end
end
