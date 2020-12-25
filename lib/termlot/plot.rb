module Termlot
  class Plot

    COLORS = {
      'r'.freeze => :red,
      'g'.freeze => :green,
      'b'.freeze => :blue,
      'c'.freeze => :cyan,
      'm'.freeze => :magenta,
      'y'.freeze => :yellow,
    }

    STYLES = {
      '-'.freeze => :lines!,
      'x'.freeze => :points!,
      ':'.freeze => :points!,
      '*'.freeze => :points!,
    }

    BORDER = {
      tl: "\u250c".freeze,
      tr: "\u2510".freeze,
      bl: "\u2514".freeze,
      br: "\u2518".freeze,
      t:  "\u2500".freeze,
      l:  "\u2502".freeze,
      b:  "\u2500".freeze,
      r:  "\u2502".freeze,
    }.freeze

    SECONDARY = :grey

    attr_writer :width, :height, :xlimits, :ylimits, :type
    attr_writer :legend, :title, :xlabel

    def initialize
      @state = []
      @color = 0
      @width, @height = :auto, :auto
      @xlimits, @ylimits = :auto, :auto
      @type = :braille
      @legend = []
      @title, @xlabel = nil, nil
      @xlines, @ylines = [], []
    end

    def xline(y)
      @xlines << y
    end

    def yline(x)
      @ylines << x
    end

    def add(*args)
      x, y, opts, style, color = *([nil] * 5)
      case args.map(&:class)
      when [Array]
        y = args[0]
      when [Array, String]
        y, opts = *args
      when [Array, Array]
        x, y = *args
      when [Array, Array, String]
        x, y, opts = *args
      else
        types = args.map(&:class).map(&:to_s).join(", ")
        raise(ArgumentError, "Cannot handle arguments of types [#{types}]")
      end
      x = (0...(y.length)).to_a unless x
      raise(ArgumentError, "Incompatible array sizes") if x.length != y.length
      if opts
        opts.chars.each do |c|
          if STYLES.keys.include?(c)
            raise(ArgumentError, "Repeated style options") if style
            style = STYLES[c]
          elsif COLORS.keys.include?(c)
            raise(ArgumentError, "Repeated color options") if color
            color = COLORS[c]
          else
            raise(ArgumentError, "Invalid option: '#{c}'")
          end
        end
      end
      style = STYLES.values.first unless style
      unless color
        color = COLORS.values[@color]
        @color += 1
      end
      @state << [style, x, y, color]
      self
    end

    def draw(out = $stdout)
      draw_top_part(out)
      draw_body(out)
      draw_bottom_part(out)
    end

    def width
      case @width
      when :auto
        TermInfo.screen_width / 2
      when :full
        TermInfo.screen_width
      else
        @width
      end
    end

    def height
      case @height
      when :auto
        TermInfo.screen_height / 2
      when :full
        TermInfo.screen_height - 1 # Leave room for a prompt.
      else
        @height
      end
    end

    def xlimits
      return @xlimits unless @xlimits == :auto
      values = @state.map { |_m, x, _y, _color| x }.flatten
      [values.min, values.max]
    end

    def ylimits
      return @ylimits unless @ylimits == :auto
      values = @state.map { |_m, _x, y, _color| y }.flatten
      [values.min, values.max]
    end

    private

    include Utils::Styler # Adds the style method.

    def xlimits_strings
      xlimits.map(&:to_s)
    end

    def ylimits_strings
      ylimits.map(&:to_s)
    end

    def canvas_width
      yticks = ylimits_strings.map(&:length).max
      legend = @legend.compact.map(&:length).max || 0
      width - yticks - (legend == 0 ? 0 : legend + 1) - 2 # 2 for the borders.
    end

    def canvas_height
      height - (title? ? 1 : 0) - 3 # 2 for the borders, 1 for the xticks.
    end

    def title?
      @title && !@title.empty?
    end

    def xlabel?
      @xlabel && !@xlabel.empty?
    end

    def canvas
      klass = Canvas.const_get(@type.to_s.capitalize.to_sym)
      minx, maxx, miny, maxy = *xlimits, *ylimits
      res = klass.new(canvas_width, canvas_height)
      @xlines.each do |y|
        y = (y - miny).fdiv(maxy - miny)
        res.lines!([0, 1], [y, y])
      end
      @ylines.each do |x|
        x = (x - minx).fdiv(maxx - minx)
        res.lines!([x, x], [0, 1])
      end
      @state.each do |method, x, y, color|
        # The canvas expects coordinates in the range 0 to 1.
        x = x.map { |v| (v - minx).fdiv(maxx - minx) }
        y = y.map { |v| (v - miny).fdiv(maxy - miny) }
        res.send(method, x, y, color)
      end
      res
    end

    def draw_top_part(out)
      out.puts(" " * (1 + (canvas_width - @title.length) / 2) + @title) if title?
      line = BORDER[:tl] + BORDER[:t] * canvas_width + BORDER[:tr]
      out.puts(style(line, SECONDARY))
    end

    def draw_bottom_part(out)
      line = BORDER[:bl] + BORDER[:b] * canvas_width + BORDER[:br]
      out.puts(style(line, SECONDARY))
      minx, maxx = *xlimits_strings
      xlabel = xlabel? ? @xlabel : ""
      left = (canvas_width - xlabel.length) / 2 - minx.length
      right = canvas_width - left - [minx, maxx, xlabel].map(&:length).sum
      line = [
        " ",
        style(minx, SECONDARY),
        " " * left,
        xlabel,
        " " * right,
        style(maxx, SECONDARY),
      ].join("")
      out.puts(line)
    end

    def draw_body(out)
      legend = @legend.zip(@state.map { |_m, _x, _y, color| color })
      legend = legend.select { |t| t.first && !t.first.empty? }
      miny, maxy = *ylimits_strings
      yticks = ylimits_strings.map(&:length).max
      canvas.drawer.each_with_index do |row, i|
        row = style(BORDER[:l], SECONDARY) + row + style(BORDER[:r], SECONDARY)
        if i == 0
          row += style(maxy, SECONDARY) + " " * (yticks - maxy.length)
        elsif i == canvas_height - 1
          row += style(miny, SECONDARY) + " " * (yticks - miny.length)
        else
          row += " " * yticks
        end
        row += " " + style(*legend[i]) if legend[i]
        out.puts(row)
      end
    end

  end
end
