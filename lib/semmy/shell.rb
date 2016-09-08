require 'rainbow'

module Semmy
  module Shell
    extend self

    attr_accessor :silence

    def info(text)
      say(text, :green)
    end

    def error(text)
      say(text, :red)
    end

    def sub_process_output(text)
      say(text, :yellow)
    end

    private

    def say(text, color)
      puts(Rainbow(text).color(color)) unless silence
    end
  end
end
