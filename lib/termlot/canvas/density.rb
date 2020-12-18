module Termlot
  module Canvas
    class Density < Base

      X_PIXEL_PER_CHAR = 1
      Y_PIXEL_PER_CHAR = 1

      CHARS = ["\u0020", "\u2591", "\u2592", "\u2593", "\u2588"].freeze

      def initialize(width, height)
        super(width, height, X_PIXEL_PER_CHAR, Y_PIXEL_PER_CHAR)
      end

      def prep(hits)
        @max = hits.flatten(1).map { |a| a.count }.max
      end

      def render(hits)
        value = hits.flatten(2).count
        char = CHARS[(value.fdiv(@max) * (CHARS.length - 1)).round]
        color = hits.flatten(2).sort_by { |t| t.first || 0 }.last&.last # The latest color.
        [char, color]
      end

    end
  end
end
