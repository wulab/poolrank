#!/usr/bin/env ruby
#
# PoolRank
# Pool game matchmaking, score keeping, and player ranking.
# https://github.com/wulab/poolrank
#
# Copyright (c) 2012 Weera Wu
# Released under the MIT license
#
require 'open-uri'
require 'tempfile'
require 'yaml'

def load_data()
  YAML.load_file($datafile)
end

def save_data(data)
  File.open($datafile, "w") do |file|
    YAML.dump(data, file)
  end
end

def generate_data_file()
  File.open($datafile, "w") do |file|
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

def initialize_data_file()
  if File.exist?($datafile)
    print("Data file already exists. Overwrite? (Y/n): ")
    if $stdin.gets().chomp == "Y"
      generate_data_file()
    end
  else
    generate_data_file()
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

def initialize_tournament()
  if matches_generated?()
    print("Tournament matches already exist. Overwrite? (Y/n): ")
    if $stdin.gets().chomp == "Y"
      generate_matches()
    end
  else
    generate_matches()
  end
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

def display_standings()
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

def display_results()
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

def display_matches()
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

def display_tables(*tables)
  tables.each do |table|
    send("display_#{table}".to_sym)
  end
end

########################################

def usage()
  puts(<<-EOF)
Usage: ruby #{File.basename(__FILE__)} <command> [<args>]

Available commands are:
  init        Create an initial data file
  new         Generate new tournament matches from data file
  show        Display tournament summary
  standings   Display current standings table
  results     Display past match results
  matches     Display remaining unplayed matches

  EOF
end

def error(message)
  format = "%{program}: %{message} See 'ruby %{program} help'."
  program = File.basename(__FILE__)
  warn(format % {:program => program, :message => message})
  exit(false)
end

def ensure_no_arguments()
  unless $argument.nil?
    error "'#{$command}' does not take argument."
  end
end

def ensure_data_file()
  unless File.exist?($datafile)
    error "'#{File.basename($datafile)}' does not exist."
  end
end

def ensure_matches_generated()
  unless matches_generated?()
    error "No generated matches in '#{File.basename($datafile)}'."
  end
end

def check_requirements(*requirements)
  requirements.each do |requirement|
    send("ensure_#{requirement}".to_sym)
  end
end

def reassign_data_file(path_or_uri)
  if path_or_uri =~ URI.regexp
    dirname, basename = File.split($datafile)
    tempfile = Tempfile.new(basename, dirname)

    begin
      IO.copy_stream(open(path_or_uri), tempfile)
      $datafile = tempfile.path()
    rescue
      error("Error retrieving '#{path_or_uri}'.")
    ensure
      tempfile.close()
    end
  elsif !path_or_uri.nil?
    $datafile = path_or_uri
  end
end

if __FILE__ == $0
  $command = ARGV.shift
  $argument = ARGV.shift
  $datafile = __FILE__.sub(File.extname(__FILE__), ".yml")

  case $command
  when nil, "help"
    usage()
  when "init"
    check_requirements(:no_arguments)
    initialize_data_file()
  when "new"
    check_requirements(:no_arguments, :data_file)
    initialize_tournament()
  when "show"
    reassign_data_file($argument)
    check_requirements(:data_file, :matches_generated)
    display_tables(:standings, :results, :matches)
  when "standings", "results", "matches"
    reassign_data_file($argument)
    check_requirements(:data_file, :matches_generated)
    display_tables($command)
  else
    error("'#{$command}' is not a valid command.")
  end
end
