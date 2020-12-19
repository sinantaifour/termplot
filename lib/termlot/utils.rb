module Termlot
  module Utils
    module Printer

      RESET = "\033[0m"

      COLORS = {
        red:     "\033[31m",
        green:   "\033[32m",
        blue:    "\033[34m",
        yellow:  "\033[33m",
        magenta: "\033[35m",
        cyan:    "\033[36m",
      }

      def print(out, chars, color)
        style = COLORS[color]
        out.print(style ? (style + chars + RESET) : chars)
      end

    end
  end
end
