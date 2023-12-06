require 'set'
require 'pry'
require 'pry-nav'
require 'json'
require 'matrix'

def read_file(file_name)
    lines = File.read(file_name).split("\n")
end

def test_equals(actual, expected)
    if actual.class != expected.class
        raise "test failed due to classes not matching, actual: #{actual.class} expected: #{expected.class}" 
    end
    if actual != expected
        raise "test failed, actual: #{actual} expected: #{expected}"
    end
end

def points_from_hits(hits)
    if hits > 0
        return 2 ** (hits - 1)
    end
    0
end
test_equals(points_from_hits(0), 0)
test_equals(points_from_hits(1), 1)
test_equals(points_from_hits(2), 2)
test_equals(points_from_hits(3), 4)
test_equals(points_from_hits(4), 8)

def points(file_name)
    lines = read_file(file_name)
    points = 0
    lines.each {|line|
        numbers = line.split(': ')[1]
        left, right = numbers.split('|')
        winning = left.split(' ').map {|number| number.to_i}
        owned = right.split(' ').map {|number| number.to_i}
        hits = 0
        owned.each {|number|
            if winning.include?(number)
                hits = hits + 1
            end
        }
        points = points + points_from_hits(hits)
    }
    points
end

test_equals points('input4.test.txt'), 13
puts points('input4.txt')