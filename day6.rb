# frozen_string_literal: true

require 'set'
require 'pry'
require 'pry-nav'
require 'json'
require 'matrix'

def read_file(file_name)
  File.read(file_name).split("\n")
end

def test_equals(actual, expected)
  if actual.class != expected.class
    raise "test failed due to classes not matching, actual: #{actual.class} expected: #{expected.class}"
  end
  return unless actual != expected

  raise "test failed, actual: #{actual} expected: #{expected}"
end

# for each race use to pointers
# first starts at zero and increments until it beats the distance
# second points starts at max time and decrements until it beats the distance
# range is from first to second (inclusive)

def win(time_held, game_time, record_distance)
  time_left = game_time - time_held
  travelled = time_left * time_held
  travelled > record_distance
end
test_equals win(0, 7, 9), false
test_equals win(1, 7, 9), false
test_equals win(2, 7, 9), true
test_equals win(3, 7, 9), true
test_equals win(4, 7, 9), true
test_equals win(5, 7, 9), true
test_equals win(6, 7, 9), false
test_equals win(7, 7, 9), false

def winning_range(game)
  game_time, record_distance = game
  left = 0
  right = game_time

  left += 1 until win(left, game_time, record_distance)
  right -= 1 until win(right, game_time, record_distance)
  (left..right).to_a.size
end
test_equals winning_range([7, 9]), 4
test_equals winning_range([15, 40]), 8
test_equals winning_range([30, 200]), 9

def multiply_ways_to_win(file_name)
  lines = read_file(file_name)
  times = lines[0].split(':')[1].split(' ').map(&:to_i)
  distances = lines[1].split(':')[1].split(' ').map(&:to_i)

  games = times.zip(distances)
  ranges = games.map do |game|
    winning_range game
  end

  ranges.reduce(:*)
end

test_equals multiply_ways_to_win('input6.test.txt'), 288
puts multiply_ways_to_win('input6.txt')
