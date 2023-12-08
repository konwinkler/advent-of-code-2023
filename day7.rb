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

module Type
  HIGH_CARD = 0
  ONE_PAIR = 1
  TWO_PAIR = 2
  THREE_OF_A_KIND = 3
  FULL_HOUSE = 4
  FOUR_OF_A_KIND = 5
  FIVE_OF_A_KIND = 6
end

def counts(cards, jokers: false)
  if !jokers
    cards.group_by { |card| card }.map { |_, group| group.size }.sort.reverse
  else
    # remove jokers
    without_jokers = cards.reject { |card| card == 'J' }
    return [5] if without_jokers.size == 0 # special case for all jokers
    counts_jokers = cards.size - without_jokers.size
    first_counts = without_jokers.group_by { |card| card }.map { |_, group| group.size }.sort.reverse
    first_counts[0] += counts_jokers
    first_counts
  end
end

# rubocop:disable Metrics/MethodLength, Metrics/CyclomaticComplexity, Metics/AbcSize, Metrics/PerceivedComplexity
def determine_type(hand, jokers: false)
  cards = hand.split('')
  counts = counts(cards, jokers: jokers)
  # binding.pry
  case counts
  when [5]
    Type::FIVE_OF_A_KIND
  when [4, 1]
    Type::FOUR_OF_A_KIND
  when [3, 2]
    Type::FULL_HOUSE
  when [3, 1, 1]
    Type::THREE_OF_A_KIND
  when [2, 2, 1]
    Type::TWO_PAIR
  when [2, 1, 1, 1]
    Type::ONE_PAIR
  else
    Type::HIGH_CARD
  end
end
# rubocop:enable Metrics/MethodLength, Metrics/CyclomaticComplexity, Metics/AbcSize, Metrics/PerceivedComplexity
test_equals determine_type('AAAAA'), Type::FIVE_OF_A_KIND
test_equals determine_type('AAAA1'), Type::FOUR_OF_A_KIND
test_equals determine_type('23332'), Type::FULL_HOUSE
test_equals determine_type('23432'), Type::TWO_PAIR
test_equals determine_type('A23A4'), Type::ONE_PAIR
test_equals determine_type('23456'), Type::HIGH_CARD
test_equals determine_type('T55J5'), Type::THREE_OF_A_KIND
test_equals determine_type('QJJQ2', jokers: true), Type::FOUR_OF_A_KIND
test_equals determine_type('JKKK2', jokers: true), Type::FOUR_OF_A_KIND
test_equals determine_type('23432', jokers: true), Type::TWO_PAIR
test_equals determine_type('JJJJJ', jokers: true), Type::FIVE_OF_A_KIND

def compare_same_type(left, right)
  left_rank = left.split('').map { |card| 'J23456789TJQKA'.index(card) }
  right_rank = right.split('').map { |card| 'J23456789TJQKA'.index(card) }
  pairs = left_rank.zip(right_rank)
  comparisons = pairs.map { |pair| pair[0] <=> pair[1] }
  comparisons.each do |comparison|
    return comparison unless comparison.zero?
  end
  0
end
test_equals compare_same_type('K', 'T'), 1
test_equals compare_same_type('2', '2'), 0
test_equals compare_same_type('2', 'K'), -1
test_equals compare_same_type('J', '2'), -1

# hand cards and bid value
class Hand
  attr_reader :cards, :bid, :jokers

  def initialize(cards, bid, jokers: false)
    @cards = cards
    @bid = bid
    @jokers = jokers
  end

  def <=>(other)
    left_type = determine_type(@cards, jokers: @jokers)
    right_type = determine_type(other.cards, jokers: other.jokers)
    if left_type != right_type
      left_type <=> right_type
    else
      compare_same_type(@cards, other.cards)
    end
  end
end
# binding.pry
test_equals(Hand.new('32T3K', 0) <=> Hand.new('KK677', 0), -1)
test_equals(Hand.new('KK677', 0) <=> Hand.new('T55J5', 0), -1)
test_equals(Hand.new('KK677', 0) <=> Hand.new('KTJJT', 0), 1)

# this is a sorting problem
# have to be able to compare two hands
def winning_total(file_name, jokers: false)
  lines = read_file(file_name)

  hands = lines.map do |line|
    parts = line.split(' ')
    Hand.new(parts[0], parts[1].to_i, jokers: jokers)
  end

  sorted_hands = hands.sort

  total = 0
  sorted_hands.each_with_index do |hand, index|
    total += hand.bid * (index + 1)
  end
  total
end

test_equals winning_total('input7.test.txt'), 6440
puts winning_total('input7.txt')

test_equals winning_total('input7.test.txt', jokers: true), 5905
puts winning_total('input7.txt', jokers: true)
