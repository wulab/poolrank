#!/usr/bin/env ruby

COMPANY = "OOZOU"
PLAYERS = ["ing", "jo", "north", "nut", "phat", "pon", "sunny"]

def generate_save_file()
  results = []
  PLAYERS.combination(2).each do |player1, player2|
    results << [player1, player2, 0]
  end
  save_to_file(results)
end

def save_to_file(results)
  file = File.new(save_file_path(), "w")
  results.each do |match|
    file.write(match.join(",") + "\n")
  end
  file.close()
end

def load_save_file()
  results = []
  file = File.open(save_file_path(), "r")
  file.each_line do |line|
    player1, player2, result = line.chomp.split(",")
    results << [player1, player2, result.to_i]
  end
  results
end

def save_file_path()
  __FILE__.sub(File.extname(__FILE__), ".csv")
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
  PLAYERS.each do |player|
    stats[player] = Hash.new(0)
  end
  stats
end

def current_standings()
  results = load_save_file()
  stats = calculate_stats(results)
  sorted_stats = stats.sort_by {|k,v| v["points"]}
  sorted_stats.reverse!

  puts
  puts "#{COMPANY} POOL TOURNAMENT".center(39)
  puts "CURRENT STANDINGS".center(39)
  puts
  puts " POS | PLAYER | WINS | LOSES | POINTS "
  puts "-----+--------+------+-------+--------"
  sorted_stats.each_with_index do |(player, pstats), index|
    wins, loses, points = pstats.values_at("wins", "loses", "points")
    template = " %3s | %-6s | %4s | %5s | %6s "
    puts template % capitalize([index+1, player, wins, loses, points])
  end
  puts
end

def match_results()
  results = load_save_file()
  unplayed = results.select { |_, _, result| !result.zero? }

  puts
  puts "#{COMPANY} POOL TOURNAMENT".center(39)
  puts "MATCH RESULTS".center(39)
  puts
  puts " NO. | MATCH                 | WINNER "
  puts "-----+-----------------------+--------"
  unplayed.each_with_index do |(player1, player2, result), index|
    versus = [player1, player2].join(" vs ")
    winner = result > 0 ? player1 : player2
    puts " %3s | %-21s | %-6s " % capitalize([index+1, versus, winner])
  end
  puts
end

def remaining_matches()
  results = load_save_file()
  unplayed = results.select { |_, _, result| result.zero? }

  puts
  puts "#{COMPANY} POOL TOURNAMENT".center(39)
  puts "REMAINING MATCHES".center(39)
  puts
  puts " NO. | MATCH                          "
  puts "-----+--------------------------------"
  unplayed.each_with_index do |(player1, player2, _), index|
    versus = [player1, player2].join(" vs ")
    puts " %3s | %-21s" % capitalize([index+1, versus])
  end
  puts
end

def capitalize(array)
  array.map do |item|
    if item.respond_to?(:upcase)
      item.upcase
    else
      item
    end
  end
end

def main()
  generate_save_file() unless File.exist?(save_file_path())
  current_standings()
  match_results()
  remaining_matches()
end

if __FILE__ == $0
  main()
end
