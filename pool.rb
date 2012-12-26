#!/usr/bin/env ruby
require 'yaml'

CFGFILE = __FILE__.sub(File.extname(__FILE__), ".yml")
SAVFILE = __FILE__.sub(File.extname(__FILE__), ".csv")

def generate_config_file()
  file = File.new(CFGFILE, "w")
  data = {"company" => "dummy", "players" => ["foo", "bar"]}
  YAML.dump(data, file)
  file.close()
end

def load_config_file()
  configs = YAML.load_file(CFGFILE)
  configs[:company] = configs["company"].upcase
  configs[:players] = configs["players"].map(&:upcase)
  configs
end

def generate_save_file()
  results = []
  configs = load_config_file()
  configs[:players].combination(2).each do |player1, player2|
    results << [player1, player2, 0]
  end
  save_to_file(results)
end

def save_to_file(results)
  file = File.new(SAVFILE, "w")
  results.each do |match|
    file.write(match.join(",") + "\n")
  end
  file.close()
end

def load_save_file()
  results = []
  file = File.open(SAVFILE, "r")
  file.each_line do |line|
    player1, player2, result = line.chomp.split(",")
    results << [player1, player2, result.to_i]
  end
  results
end

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

def initialize_stats()
  stats = {}
  configs = load_config_file()
  configs[:players].each do |player|
    stats[player] = Hash.new(0)
  end
  stats
end

def current_standings()
  configs = load_config_file()
  results = load_save_file()
  stats = calculate_stats(results)
  sorted_stats = stats.sort_by { |_, value| value["points"] }
  sorted_stats.reverse!

  puts
  puts "#{configs[:company]} POOL TOURNAMENT".center(39)
  puts "CURRENT STANDINGS".center(39)
  puts
  puts " POS | PLAYER | WINS | LOSES | POINTS "
  puts "-----+--------+------+-------+--------"
  sorted_stats.each_with_index do |(player, pstats), index|
    wins, loses, points = pstats.values_at("wins", "loses", "points")
    template = " %3s | %-6s | %4s | %5s | %6s "
    puts template % [index+1, player, wins, loses, points]
  end
  puts
end

def match_results()
  configs = load_config_file()
  results = load_save_file()
  unplayed = results.select { |_, _, result| !result.zero? }

  puts
  puts "#{configs[:company]} POOL TOURNAMENT".center(39)
  puts "MATCH RESULTS".center(39)
  puts
  puts " NO. | MATCH                 | WINNER "
  puts "-----+-----------------------+--------"
  unplayed.each_with_index do |(player1, player2, result), index|
    versus = [player1, player2].join(" vs ")
    winner = result > 0 ? player1 : player2
    puts " %3s | %-21s | %-6s " % [index+1, versus, winner]
  end
  puts
end

def remaining_matches()
  configs = load_config_file()
  results = load_save_file()
  unplayed = results.select { |_, _, result| result.zero? }

  puts
  puts "#{configs[:company]} POOL TOURNAMENT".center(39)
  puts "REMAINING MATCHES".center(39)
  puts
  puts " NO. | MATCH                          "
  puts "-----+--------------------------------"
  unplayed.each_with_index do |(player1, player2, _), index|
    versus = [player1, player2].join(" vs ")
    puts " %3s | %-21s" % [index+1, versus]
  end
  puts
end

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
