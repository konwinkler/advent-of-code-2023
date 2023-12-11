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
  attr_accessor :is_start, :up, :down, :left, :right, :x, :y

  def initialize(x, y)
    @x = x
    @y = y
    @is_start = false
  end

  def set_entry_points(up: false, down: false, left: false, right: false)
    @up = up
    @down = down
    @left = left
    @right = right
  end

  def move_next(previous, map)
    # determin entry_point direction
    entry_direction = if previous.x < x
                        :left
                      elsif previous.x > x
                        :right
                      elsif previous.y < y
                        :up
                      elsif previous.y > y
                        :down
                      else
                        binding.pry
                        raise 'could not determine entry direction'
                      end
    # determine exit_point direction
    exit_direction = if left && entry_direction != :left
                        :left
                      elsif right && entry_direction != :right
                        :right
                      elsif up && entry_direction != :up
                        :up
                      elsif down && entry_direction != :down
                        :down
                      else
                        raise 'could not determine exit direction'
                      end
    # find next node
    case exit_direction
    when :up
      map.find { |node| node.x == x && node.y == y - 1 }
    when :down
      map.find { |node| node.x == x && node.y == y + 1 }
    when :left
      map.find { |node| node.x == x - 1 && node.y == y }
    when :right
      map.find { |node| node.x == x + 1 && node.y == y }
    else
      raise 'unknown exit direction'
    end
  end
end

def parse_map(lines)
  nodes = []
  lines.each_with_index do |line, y|
    parts = line.split('')
    parts.each_with_index do |part, x|
      node = Node.new(x, y)
      case part
      when '.'
        # no op
      when '|'
        node.set_entry_points(up: true, down: true)
      when '-'
        node.set_entry_points(left: true, right: true)
      when 'F'
        node.set_entry_points(down: true, right: true)
      when '7'
        node.set_entry_points(down: true, left: true)
      when 'J'
        node.set_entry_points(up: true, left: true)
      when 'L'
        node.set_entry_points(up: true, right: true)
      when 'S'
        node.is_start = true
      else
        raise "unknown part: #{part}"
      end
      nodes.push(node)
    end
  end

  nodes
end

def find_start(map)
  map.find(&:is_start)
end

def pick_next(start, map)
  # right
  node = map.find { |node| node.x == start.x + 1 && node.y == start.y && node.left }
  return node if node
  # left
  node = map.find { |node| node.x == start.x - 1 && node.y == start.y && node.right }
  return node if node
  # up
  node = map.find { |node| node.x == start.x && node.y == start.y - 1 && node.down }
  return node if node
  # down
  node = map.find { |node| node.x == start.x && node.y == start.y + 1 && node.up }
  return node if node
  raise 'could not find next node'
end

def farthest_point(file_name)
  lines = read_file(file_name)
  map = parse_map(lines)

  start = find_start(map)
  current = pick_next(start, map)
  distance = 1
  previous = start
  until current.is_start
    old = current
    current = current.move_next(previous, map)
    previous = old
    distance += 1
  end
  (distance / 2).to_i # rounds down
end

test_equals farthest_point('input10.test.txt'), 8
puts farthest_point('input10.txt')
