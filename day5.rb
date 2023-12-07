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

def parse_numbers(lines)
  lines.map { |line| line.split(' ').map(&:to_i) }
end

def parse_function(destination, source)
  ->(x) { x - source + destination }
end
test_equals parse_function(50, 98).call(98), 50
test_equals parse_function(50, 98).call(99), 51
test_equals parse_function(52, 50).call(50), 52

def parse_map_string(map_string)
  lines = map_string.split("\n")
  numbers = parse_numbers(lines.drop(1))
  # so we have a range
  # and a function
  numbers.map do |destination, source, range|
    range = (source..source + range - 1)
    foo = parse_function(destination, source)
    [range, foo]
  end
end

def follow_transition(seed, transition)
  transition.each do |range, function|
    return function.call(seed) if range.include?(seed)
  end
  seed
end

def cache
  @cache ||= {}
end

def follow_seed(seed, transitions, use_cache: false)
  return cache[seed] if use_cache && cache[seed]

  original_seed = seed
  transitions.each do |transition|
    seed = follow_transition(seed, transition)
  end

  cache[original_seed] = seed if use_cache
  seed
end
test_equals follow_seed(0, [[[(0..2), ->(x) { x + 1 }]]]), 1
test_equals follow_seed(0, [[[(0..1), ->(x) { x + 2 }],[(2..4), ->(x) { x + 10 }]]]), 2
test_equals follow_seed(0, [[[(0..2), ->(x) { x + 1 }]],[[(0..2), ->(x) { x + 5 }]]]), 6
test_equals follow_seed(5, [[[(0..2), ->(x) { x + 1 }]]]), 5

def lowest_location(file_name)
  sections = File.read(file_name).split("\n\n")
  seeds = sections[0].split(': ')[1].split(' ').map(&:to_i)
  transitions = sections.drop(1).map { |section| parse_map_string(section) }

  locations = seeds.map { |seed| follow_seed(seed, transitions) }

  locations.min
end

test_equals lowest_location('input5.test.txt'), 35
puts lowest_location('input5.txt')

def follow_seeds(seeds, transitions)
  total = []
  binding.pry
  seeds.each_slice(2) do |start, range|
    locations = (start..start + range).map { |seed| follow_seed(seed, transitions, use_cache: true) }
    total += locations
    puts "done with #{start} to #{start + range}"
  end
  total
end

def lowest_location_ranges(file_name)
  sections = File.read(file_name).split("\n\n")
  seeds = sections[0].split(': ')[1].split(' ').map(&:to_i)
  transitions = sections.drop(1).map { |section| parse_map_string(section) }

  locations = follow_seeds(seeds, transitions)

  locations.min
end

test_equals lowest_location_ranges('input5.test.txt'), 46
cache.clear
puts lowest_location_ranges('input5.txt')
