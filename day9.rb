# frozen_string_literal: true

require 'set'
require 'pry'
require 'pry-nav'

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

def parse_history(line)
  line.split(' ').map(&:to_i)
end

def next_value(history, backwards: false)
  return 0 if history.all?(&:zero?)

  difference_sequence = history.drop(1).map.with_index do |value, index|
    value - history[index]
  end

  next_lower_value = next_value(difference_sequence, backwards:)

  if !backwards
    history.last + next_lower_value
  else
    history.first - next_lower_value
  end
end
test_equals next_value([0, 0, 0, 0]), 0
test_equals next_value([3, 3, 3, 3, 3]), 3
test_equals next_value([0, 3, 6, 9, 12, 15]), 18
test_equals next_value([3, 3, 3, 3, 3], backwards: true), 3
test_equals next_value([0, 3, 6, 9, 12, 15], backwards: true), -3
test_equals next_value([0, 2, 4, 6], backwards: true), -2
test_equals next_value([3, 3, 5, 9, 15], backwards: true), 5
test_equals next_value([10, 13, 16, 21, 30, 45], backwards: true), 5
test_equals next_value([1, 3, 6, 10, 15, 21], backwards: true), 0

def sum_next_value(file_name, backwards: false)
  lines = read_file(file_name)
  histories = lines.map { |line| parse_history(line) }
  next_values = histories.map { |history| next_value(history, backwards:) }
  next_values.sum
end

test_equals sum_next_value('input9.test.txt'), 114
puts sum_next_value('input9.txt')

test_equals sum_next_value('input9.test.txt', backwards: true), 2
puts sum_next_value('input9.txt', backwards: true)
