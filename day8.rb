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

class Node
  attr_accessor :name, :left, :right

  def initialize(name, left, right)
    @name = name
    @left = left
    @right = right
  end
end

def parse_nodes(lines)
  lines.map do |line|
    parts = line.split(' = ')
    name = parts[0]
    destinations = parts[1].split(', ')
    left = destinations[0].split('(')[1]
    right = destinations[1].split(')')[0]
    Node.new(name, left, right)
  end
end

def follow_instructions(instructions, mappings)
  current = mappings.find { |node| node.name == 'AAA' }
  counter = 0
  until current.name == 'ZZZ'
    current = if instructions[counter % instructions.size] == 'L'
                mappings.find { |node| node.name == current.left }
              else
                mappings.find { |node| node.name == current.right }
              end
    counter += 1
  end
  counter
end

def steps(file_name)
  lines = read_file(file_name)
  instructions = lines[0].split('')
  mappings = parse_nodes(lines.drop(2))

  follow_instructions(instructions, mappings)
end

test_equals steps('input8.test.txt'), 6
puts steps('input8.txt')
