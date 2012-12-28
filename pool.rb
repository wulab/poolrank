#!/usr/bin/env ruby
require 'yaml'

CFGFILE = __FILE__.sub(File.extname(__FILE__), ".yml")
SAVFILE = __FILE__.sub(File.extname(__FILE__), ".csv")

def generate_config_file()
  File.open(CFGFILE, "w") do |file|
    data = {"company" => "dummy", "players" => ["foo", "bar"]}
    YAML.dump(data, file)
  end
end

def load_config_file()
  YAML.load_file(CFGFILE)
end

def generate_save_file()
  results = []
  configs = load_config_file()
  configs["players"].combination(2).each do |player1, player2|
    results << [player1, player2, 0]
  end
  save_to_file(results)
end

def save_to_file(results)
  File.open(SAVFILE, "w") do |file|
    results.each do |match|
      file.write(match.join(",") + "\n")
    end
  end
end

def load_save_file()
  results = []
  File.open(SAVFILE, "r") do |file|
    file.each do |line|
      player1, player2, result = line.chomp.split(",")
      results << [player1, player2, result.to_i]
    end
  end
  results
end

########################################

def calculate_stats(results)
  stats = initialize_stats()
  results.each do |player1, player2, result|
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

def initialize_stats()
  stats = {}
  configs = load_config_file()
  configs["players"].each do |player|
    stats[player] = Hash.new(0)
  end
  stats
end

def disp(text=nil)
  indent = "  "
  text = (indent << text).upcase unless text.nil?
  puts text
end

########################################

def current_standings()
  configs = load_config_file()
  results = load_save_file()
  rankings = assign_rankings(calculate_stats(results))

  disp
  disp "#{configs["company"]} POOL TOURNAMENT".center(38)
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
  configs = load_config_file()
  results = load_save_file()
  unplayed = results.select { |_, _, result| !result.zero? }

  disp
  disp "#{configs["company"]} POOL TOURNAMENT".center(38)
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
  configs = load_config_file()
  results = load_save_file()
  unplayed = results.select { |_, _, result| result.zero? }

  disp
  disp "#{configs["company"]} POOL TOURNAMENT".center(38)
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

########################################

def main()
  generate_config_file() unless File.exist?(CFGFILE)
  generate_save_file() unless File.exist?(SAVFILE)
  current_standings()
  match_results()
  remaining_matches()
end

if __FILE__ == $0
  main()
end
