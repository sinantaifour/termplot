module Termplot
  module Canvas
    class Dot < Base

      X_PIXEL_PER_CHAR = 1
      Y_PIXEL_PER_CHAR = 2

      CHARS = {
        [0, 0] => " ",
        [0, 1] => ".",
        [1, 0] => "'",
        [1, 1] => ":",
      }.freeze

      def initialize(width, height)
        super(width, height, X_PIXEL_PER_CHAR, Y_PIXEL_PER_CHAR)
      end

      def render(hits)
        char = CHARS[hits.flatten(1).map{ |a| a.empty? ? 0 : 1 }]
        color = hits.flatten(2).sort_by { |t| t.first || 0 }.last&.last # The latest color.
        [char, color]
      end

    end
  end
end
