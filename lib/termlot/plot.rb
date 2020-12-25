module Termlot
  class Plot

    MIN = {
      width: 20,
      height: 10,
    }.freeze

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

    attr_reader :width, :height, :xlimits, :ylimits, :type
    attr_writer :legend, :title, :xlabel # TODO: Add sanity checks.

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
      # Fill x, y, and opts based on args.
      x, y, opts = nil, nil, ""
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
      # Parse style and color out of opts.
      style, color = nil, nil
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
      # Fill style and color if not provided from opts.
      style = STYLES.values.first unless style
      unless color
        color = COLORS.values[@color]
        @color += 1
      end
      # Add to state.
      @state << [style, x, y, color]
      self
    end

    def draw
      draw_top_part
      draw_body
      draw_bottom_part
    end

    [:width, :height].each do |dim|
      define_method(:"#{dim}=") do |value|
        if [:auto, :full].include?(value) || (value.is_a?(Integer) && value > 0)
          too_small = value.is_a?(Integer) && value <= MIN[dim]
          raise(ArgumentError, "Value too small") if too_small
        else
          raise(ArgumentError, "Invalid value")
        end
        instance_variable_set(:"@#{dim}", value)
      end
    end

    [:xlimits, :ylimits].each do |lim|
      define_method(:"#{lim}=") do |value|
        if value == :auto || value.is_a?(Array) && value.length == 2
          wrong_order_or_zero = (value[1] - value[0]) <= 0
          raise(ArgumentError, "Limits are not valid") if wrong_order_or_zero
        else
          raise(ArgumentError, "Invalid value")
        end
        instance_variable_set(:"@#{lim}", value)
      end
    end

    def type=(value)
      mod = Termlot::Canvas
      canvases = mod.constants.select { |c| mod.const_get(c) < mod::Base }
      valid = canvases.map { |s| s.to_s.downcase.to_sym }
      raise(ArgumentError, "Invalid value") unless valid.include?(value)
      @type = value
    end

    def calculated_width
      case @width
      when :auto
        TermInfo.screen_width / 2
      when :full
        TermInfo.screen_width
      else
        @width
      end
    end

    def calculated_height
      case @height
      when :auto
        TermInfo.screen_height / 2
      when :full
        TermInfo.screen_height - 1 # Leave room for a prompt.
      else
        @height
      end
    end

    def calculated_xlimits
      return @xlimits unless @xlimits == :auto
      values = @state.map { |_m, x, _y, _color| x }.flatten
      [values.min, values.max]
    end

    def calculated_ylimits
      return @ylimits unless @ylimits == :auto
      values = @state.map { |_m, _x, y, _color| y }.flatten
      [values.min, values.max]
    end

    private

    include Utils::Styler # Adds the style method.

    def xlimits_strings
      calculated_xlimits.map(&:to_s)
    end

    def ylimits_strings
      calculated_ylimits.map(&:to_s)
    end

    def canvas_width
      yticks = ylimits_strings.map(&:length).max
      legend = @legend.compact.map(&:length).max || 0
      res = calculated_width - yticks - (legend == 0 ? 0 : legend + 1)
      res - 2 # 2 for the borders.
    end

    def canvas_height
      res = calculated_height - (title? ? 1 : 0)
      res - 3 # 2 for the borders, 1 for the xticks.
    end

    def title?
      @title && !@title.empty?
    end

    def xlabel?
      @xlabel && !@xlabel.empty?
    end

    def canvas
      klass = Canvas.const_get(@type.to_s.capitalize.to_sym)
      minx, maxx, miny, maxy = *calculated_xlimits, *calculated_ylimits
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

    def draw_top_part
      puts(" " * (1 + (canvas_width - @title.length) / 2) + @title) if title?
      line = BORDER[:tl] + BORDER[:t] * canvas_width + BORDER[:tr]
      puts(style(line, SECONDARY))
    end

    def draw_bottom_part
      line = BORDER[:bl] + BORDER[:b] * canvas_width + BORDER[:br]
      puts(style(line, SECONDARY))
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
      puts(line)
    end

    def draw_body
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
        puts(row)
      end
    end

  end
end
