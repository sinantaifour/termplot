module Termlot
  module Canvas
    class Braille < Base

      X_PIXEL_PER_CHAR = 2
      Y_PIXEL_PER_CHAR = 4

      FILL = 0x2800

      CHARS = [
        [0x01, 0x08].freeze,
        [0x02, 0x10].freeze,
        [0x04, 0x20].freeze,
        [0x40, 0x80].freeze,
      ].freeze

      def initialize(width, height)
        super(width, height, X_PIXEL_PER_CHAR, Y_PIXEL_PER_CHAR)
      end

      def render(hits)
        char = FILL
        (0...Y_PIXEL_PER_CHAR).each do |y|
          (0...X_PIXEL_PER_CHAR).each do |x|
            char = char | CHARS[y][x] unless hits[y][x].empty?
          end
        end
        char = char.chr(Encoding::UTF_8)
        color = hits.flatten(2).sort_by { |t| t.first || 0 }.last&.last # The latest color.
        [char, color]
      end

    end
  end
end
