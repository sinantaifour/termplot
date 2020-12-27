#!/usr/bin/env ruby

# This script requires the `convert` binary and `chunky_png` gem to be
# installed first. Unfortunately, resizing with ChunkyPNG directly does not
# yield good enough results.

require 'chunky_png'

FILENAME = File.expand_path File.dirname(__FILE__) + "/intensities.png"
TMP = "/tmp/tmp-char.png"
CHARS = (
  "!\"\#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ" +
  "[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~"
).freeze

png = ChunkyPNG::Image.from_file(FILENAME)

if png.width / CHARS.length != png.width.fdiv(CHARS.length)
  puts "The width of the PNG is not a multiple of #{CHARS.length}."
  exit(1)
end

width = png.width / CHARS.length
height = png.height

puts "INTENSITIES = {"
CHARS.chars.each_with_index do |char, i|
  cmd = (
    "convert '#{FILENAME}' -crop #{width}x#{height}+#{i * width}+0 " +
    "-resize 3x3! -filter point -colorspace gray '#{TMP}'"
  )
  `#{cmd}`
  pixels = ChunkyPNG::Image.from_file(TMP).pixels
  pixels = pixels.map { |v| v >> 4 * 6 }
  pixels = pixels.map { |v| v.fdiv(pixels.max).round(2) }
  pixels = pixels.map(&:to_s).join(", ")
  puts "  #{char.inspect} => [#{pixels}].freeze,"
end
puts "}.freeze"
