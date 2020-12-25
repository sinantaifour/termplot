module Termlot
  module Utils
    module Styler

      RESET = "\033[0m"

      COLORS = {
        red:     "\033[31m",
        green:   "\033[32m",
        blue:    "\033[34m",
        yellow:  "\033[33m",
        magenta: "\033[35m",
        cyan:    "\033[36m",
        grey:    "\033[90m",
      }

      def style(chars, color)
        command = COLORS[color]
        command ? (command + chars + RESET) : chars
      end

    end
  end
end
