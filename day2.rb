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

# Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
def parse_game(line)
    rounds = line.split(':')[1]
    game = rounds.split(';').map {|round|
        #  3 blue, 4 red
        round.split(',').map {|color|
            # 3 blue
            parts = color.split(' ')
            [parts[1].strip, parts[0].to_i]
        }.to_h
    }
    game
end

# only 12 red cubes, 13 green cubes, and 14 blue cubes
def is_valid_game?(line)
    game = parse_game(line)

    game.each {|round|
        round.each {|color, count|
            if color == 'red' && count > 12
                return false
            end
            if color == 'green' && count > 13
                return false
            end
            if color == 'blue' && count > 14
                return false
            end
        }
    }
    true
end

def sum_ids_valid_games(file_name)
    lines = read_file(file_name)
    valid_games = lines.map.with_index {|line, index| 
        is_valid_game?(line) ? index + 1 : 0
    }
    valid_games.sum
end


test_equals(sum_ids_valid_games('input2.test.txt'), 8)
puts sum_ids_valid_games('input2.txt')