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

def calibration(file_name)
    lines = read_file(file_name)
    numbers = lines.map {|line| 
        first_and_last_digit(line)
    }
    numbers.sum
end

def first_and_last_digit(text)
    numbers = text.chars.filter {|char|
        is_number?(char)
    }
    (numbers.first + numbers.last).to_i
end

def is_number?(character)
    return true if Float(character) rescue false
end
# binding.pry

test_equals(first_and_last_digit('12'), 12)
test_equals(first_and_last_digit('1asdvxcx3'), 13)
test_equals(first_and_last_digit('1asdvxcx'), 11)
test_equals(calibration('input1.test.txt'), 142)

puts calibration('input1.txt')
