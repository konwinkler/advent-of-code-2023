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

def calculate_counts(wins)
    # initialize all cards with count 1
    counts = wins.map {|win| 1}
    # add up the copies
      # card 1, count 1 -> adds 1 to cards 2, 3, 4, 5
      # card 2, count 2 -> adds 2 to cards 3, 4
    wins.each_with_index {|hits, index|
        current_count = counts[index]
        (index+1..index+hits).to_a.each {|add_index|
            if (add_index < counts.length)
                counts[add_index] = counts[add_index] + current_count
            end
        }
    }
    counts
end
test_equals calculate_counts([1]), [1]
test_equals calculate_counts([1, 1]), [1, 2]
test_equals calculate_counts([2, 1, 1]), [1, 2, 4]

def total_scratchcards(file_name)
    # calculate for each cards how many wins they get
      # card 1 wins 4 times
      # card 2 wins 2 times
      lines = read_file(file_name)
      wins = []
      lines.each_with_index {|line, line_index|
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
          wins.push(hits)
      }

    counts = calculate_counts(wins)
    

    # sum all counts at the end
    counts.sum
end

test_equals total_scratchcards('input4.test.txt'), 30
puts total_scratchcards('input4.txt')