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

def is_number?(string)
    true if Float(string) rescue false
end
test_equals(is_number?('1'), true)
test_equals(is_number?('a'), false)

def is_symbol?(string)
    string != '.' && !is_number?(string)
end
test_equals(is_symbol?('.'), false)
test_equals(is_symbol?('1'), false)
test_equals(is_symbol?('-'), true)
test_equals(is_symbol?('+'), true)

def generate_boundary(x, y, width, height)
    boundaries = Set[]
    [-1, 0, 1].each {|x_offset|
        [-1, 0, 1].each {|y_offset|
            new_x = x + x_offset
            new_y = y + y_offset
            if new_x == x && new_y == y
                next
            end
            if new_x >= 0 && new_x < width && new_y >= 0 && new_y < height
                boundaries.add([new_x, new_y])
            end
        }
    }
    boundaries
end
test_equals(generate_boundary(0, 0, 3, 3), Set[[1, 0], [0, 1], [1, 1]])
test_equals(generate_boundary(1, 1, 3, 3), Set[[0, 0], [1, 0], [2, 0], [0, 1], [2, 1], [0, 2], [1, 2], [2, 2]])

def add_number(current_number, character)
    current = character.to_i
    if current_number != 0
        current_number = current_number * 10
    end
    current_number = current_number + current
end
test_equals(add_number(9, '0'), 90)

def parse_line(line, line_index, width, height)
    numbers = []
    current_number = 0
    current_boundary = Set[]
    characters = line.split('')
    characters.each_with_index {|character, character_index|
        if is_number?(character)
            current_number = add_number(current_number, character)
            current_boundary = current_boundary | generate_boundary(character_index, line_index, width, height)
        else
            if (current_number != 0)
                numbers.push([current_number, current_boundary.clone])
            end
            current_number = 0
            current_boundary.clear
        end
    }
    if (current_number != 0)
        numbers.push([current_number, current_boundary.clone])
    end
    # binding.pry
    numbers
end
test_equals(parse_line('...123.', 0, 7, 1), [[123, Set[[2,0], [3,0], [4,0], [5,0], [6,0]]]])
test_equals(parse_line('...123', 0, 6, 1), [[123, Set[[2,0], [3,0], [4,0], [5,0]]]])

def sum_adjacent(file_name)
    lines = read_file(file_name)
    height = lines.length
    width = lines[0].length

    numbers = []
    lines.each_with_index {|line, line_index|
        numbers.concat(parse_line(line, line_index, width, height))

    }
    hits = numbers.map {|number, boundary|
        hit = false
        boundary.to_a.each {|x, y|
            if is_symbol?(lines[y][x])
                hit = true
                # binding.pry
            end
        }
        hit ? number : 0
    }
    # binding.pry
    hits.sum
end

test_equals(sum_adjacent('input3.test.txt'), 4361)
puts sum_adjacent('input3.txt')
# 431790 was too low
# 534318 was too low