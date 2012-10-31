require 'set'
require 'benchmark/ips'

non_match   = Array.new(100).map { |*| rand(10_000_000) }
early_match = [-1] + non_match
late_match  = non_match + [-1]

s_non_match   = Set.new(non_match)
s_early_match = Set.new(early_match)
s_late_match  = Set.new(late_match)

Benchmark.ips do |x|
  x.report('Array: non-match')   { non_match.include?(-1) }
  x.report('Set: non-match')     { s_non_match.include?(-1) }

  x.report('Array: early-match') { early_match.include?(-1) }
  x.report('Set: early-match')   { s_early_match.include?(-1) }

  x.report('Array: late-match')  { late_match.include?(-1) }
  x.report('Set: late-match')    { s_late_match.include?(-1) }

  x.report('Set setup:')         { Set.new(non_match) }
end
