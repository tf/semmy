require 'rainbow'

module Semmy
  module Shell
    extend self

    attr_accessor :silence

    def info(text)
      say(text, :green)
    end

    def warn(text)
      say(text, :yellow)
    end

    def error(text)
      say(text, :red)
    end

    private

    def say(text, color)
      puts(Rainbow(text).color(color)) unless silence
    end
  end
end
