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

def calibration_full_words(file_name)
    lines = read_file(file_name)
    numbers = lines.map {|line| 
        first_and_last_digit_full_words(line)
    }
    numbers.sum
end

def first_and_last_digit_full_words(text)
    numbers = []
    length = text.size
    while length > 0
        number = is_number_full_words?(text.chars.last(length).join)
        if number != nil
            numbers << number
        end
        length -= 1
    end
    (numbers.first.to_s + numbers.last.to_s).to_i
end

$number_words = {'one' => 1, 'two' => 2, 'three' => 3, 'four' => 4, 'five' => 5,'six' => 6, 'seven' => 7, 'eight' => 8, 'nine' => 9}
def is_number_full_words?(text)
    return text.chars.first.to_i if is_number?(text.chars.first)
    $number_words.keys.each do |key|
        return $number_words[key] if text.start_with?(key)
    end
    return nil
end

test_equals(is_number_full_words?('1'), 1)
test_equals(is_number_full_words?('one'), 1)
test_equals(is_number_full_words?('ont'), nil)
test_equals(is_number_full_words?('two'), 2)

test_equals(first_and_last_digit_full_words('one1'), 11)
test_equals(first_and_last_digit_full_words('one1two'), 12)

test_equals(calibration_full_words('input1.test2.txt'), 281)
puts calibration_full_words('input1.txt')