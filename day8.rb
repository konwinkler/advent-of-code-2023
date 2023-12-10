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

# can move left or right
class Node
  attr_accessor :name, :left, :right

  def initialize(name)
    @name = name
  end

  def end?
    @end ||= @name.slice(-1) == 'Z'
  end
end

def parse_nodes(lines)
  nodes = lines.map do |line|
    parts = line.split(' = ')
    name = parts[0]
    Node.new(name)
  end
  lines.each do |line|
    parts = line.split(' = ')
    name = parts[0]
    destinations = parts[1].split(', ')
    left = destinations[0].split('(')[1]
    right = destinations[1].split(')')[0]
    node = nodes.find { |n| n.name == name }
    node.left = nodes.find { |n| n.name == left }
    node.right = nodes.find { |n| n.name == right }
  end
  nodes
end

def follow_instructions(instructions, mappings)
  current = mappings.find { |node| node.name == 'AAA' }
  counter = 0
  until current.name == 'ZZZ'
    current = if instructions[counter % instructions.size] == 'L'
                current.left
              else
                current.right
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

def all_end_with_z?(nodes)
  nodes.all?(&:end?)
end

def follow_ghost_instructions(instructions, mappings)
  current_nodes = mappings.select { |node| node.name.slice(-1) == 'A' }
  counter = 0

  until all_end_with_z?(current_nodes)
    current_nodes = current_nodes.map do |node|
      if instructions[counter % instructions.size] == 'L'
        node.left
      else
        node.right
      end
    end
    counter += 1
    puts "counter #{counter}" if (counter % 1_000_000).zero?
  end
  counter
end

def ghost_steps(file_name)
  lines = read_file(file_name)
  instructions = lines[0].split('')
  mappings = parse_nodes(lines.drop(2))

  follow_ghost_instructions(instructions, mappings)
end

test_equals ghost_steps('input8.test2.txt'), 6
puts ghost_steps('input8.txt')
