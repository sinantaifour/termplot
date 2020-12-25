module Termlot

  # Using this module helps us maintain state of the interactive session
  # without polluting the namespace that's using it with variables.
  module State

    def self.[]=(key, value)
      @state ||= {}
      @state[key] = value
    end

    def self.[](key)
      @state ||= {}
      @state[key]
    end

    def self.clear
      @state = {}
    end

  end

  module Interactive

    # Calling this method `clear` caused unexpected behavior when using pry.
    def reset!
      State.clear
      nil
    end

    def plot(*args)
      p = State[:plot] if State[:hold]
      p = Plot.new unless p
      State[:plot] = p
      p.add(*args)
      redraw
    end

    def hold(value = :on)
      raise(ArgumentError, "Unknown value") unless [:on, :off].include?(value)
      State[:hold] = value == :on
      nil
    end

    def redraw
      p = State[:plot]
      if p
        (State[:props] || {}).each { |k, v| p.send(:"#{k}=", v) }
        p.draw
      end
      nil
    end

    [
      :width, :height, :xlimits, :ylimits,
      :type, :legend, :title, :xlabel
    ].each do |m|
      define_method(m) do |value|
        Plot.new.send(:"#{m}=", value) # Expose potential exceptions.
        State[:props] ||= {}
        State[:props][m] = value
        redraw
      end
    end

  end
end

