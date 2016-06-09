require 'rainbow'

module Semmy
  module Shell
    extend self

    attr_accessor :silence

    def info(text)
      say(text, :green)
    end

    private

    def say(text, color)
      puts(Rainbow(text).color(color)) unless silence
    end
  end
end
