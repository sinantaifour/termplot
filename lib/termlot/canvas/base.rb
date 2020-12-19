module Termlot
  module Canvas
    class Base

      attr_reader :width
      attr_reader :height

      def initialize(width, height, x_pixel_per_char, y_pixel_per_char)
        @width = width
        @height = height
        @x_pixel_per_char = x_pixel_per_char
        @y_pixel_per_char = y_pixel_per_char
        @hits = (0..maxpy).map { (0..maxpx).map { [] } }
      end

      def draw(out = $stdout)
        prep(@hits)
        (0...@height).each do |cy|
          (0...@width).each do |cx|
            sub = (0...@y_pixel_per_char).map { [nil] * @x_pixel_per_char }
            (0...@y_pixel_per_char).each do |j|
              (0...@x_pixel_per_char).each do |i|
                sub[j][i] = @hits[cy * @y_pixel_per_char + j][cx * @x_pixel_per_char + i]
              end
            end
            char, color = render(sub)
            print(out, char, color)
          end
          out.puts
        end
      end

      def points!(x, y, color = nil)
        (0...x.length).each do |i|
          hit!(x[i], y[i], color)
        end
        self
      end

      def lines!(x, y, color = nil)
        (0...(x.length - 1)).each do |i|
          line!(x[i], y[i], x[i+1], y[i+1], color)
        end
        self
      end

      def inspect
        atts = [:width, :height].map do |a|
          "@#{a}=#{instance_variable_get(:"@#{a}").inspect}"
        end
        "#<#{self.class} (#{@hits.flatten(2).count} hits) #{atts.join(", ")}>"
      end

      private

      include Utils::Printer # Adds the print method.

      def render(hits)
        # Implemented by subclasses. Given the hits corresponding to this
        # character of the screen, return a tuple [char, color] of what should
        # be printed.
        # The argument hits is an array of arrays of tuples [counter, color].
        # It's indexed in the y-direction first, and has size y_pixel_per_char
        # times x_pixel_per_char.
      end

      def prep(hits)
        # Optionally implemented by subclasses to prepare for rendering. All
        # hits are passed. See render above for a definition of hits.
      end

      def line!(x1, y1, x2, y2, color) # Using the DDA algorithm.
        w, h = x2 - x1, y2 - y1
        n = [w.abs * pw, h.abs * ph].max
        dx, dy = w.fdiv(n), h.fdiv(n)
        x, y = x1, y1
        hit!(x, y, color)
        (1..n).each do
          x += dx
          y += dy
          hit!(x, y, color)
        end
      end

      def pw # Width in pixels.
        @width * @x_pixel_per_char
      end

      def ph # Height in pixels.
        @height * @y_pixel_per_char
      end

      def maxpx # Maximum pixel x-coordinate.
        pw - 1
      end

      def maxpy # Maximum pixel y-coordinate.
        ph - 1
      end

      def hit!(x, y, color)
        px, py = *[x * maxpx, (1 - y) * maxpy].map(&:round)
        cell = @hits[py]&.[](px)
        return if px < 0 || py < 0 || cell.nil? # Don't hit out of bounds.
        cell << [x, y, color]
      end

    end
  end
end
