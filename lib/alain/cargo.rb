# frozen_string_literal: true
require 'tomlrb'

module Alain #:nodoc:
  attr_reader :cargo
  class Cargo
    def initialize(dir = '.')
      toml = Pathname(dir) / 'Cargo.toml'
      unless File.exist? toml
        puts "./Cargo.toml not found. 'cargo new' first."
        exit 1
      end
      @cargo = Tomlrb.load_file toml
    end

    def add_dependencies
      toml = Pathname('.') / 'Cargo.toml'
      origin = File.read toml
      File.open(toml, 'w') do |f|
        origin.each_line do |line|
          if /^\[dependencies\]/.match(line)
            f.puts line
            dependencies.each do |k, entry|
              next if @cargo['dependencies'].keys.include? k
              f.puts entry
            end
          elsif /^\[build-dependencies\]/.match(line)
            f.puts line
            build_dependencies.each do |k, entry|
              next if @cargo['build-dependencies'].keys.include? k
              f.puts entry
            end
          else
            f.puts line
          end
        end
        unless @cargo['build-dependencies']
          f.puts '[build-dependencies]'
          f.puts build_dependencies.values.join("\n")
        end
      end
    end

    def crate_name
      @cargo.dig('package', 'name').gsub(/-/, '_')
    end

    private

    def dependencies
      {
        'once_cell' => %(once_cell = "1.5"),
        'prost' => %(prost = "0.7"),
        'prost-types' => %(prost-types = "0.7"),
        'signal-hook' => %(signal-hook = "0.3.9"),
        'signal-hook-tokio' => %(signal-hook-tokio = { version = "0.3.0", features = ["futures-v0_3"] }),
        'tokio' => %(tokio = { version = "1.0", features = ["full"] }),
        'tokio-stream' => %(tokio-stream = "0.1.2"),
        'tonic' => %(tonic = "0.4.0"),
        'triggered' => %(triggered = "0.1.1")
      }
    end

    def build_dependencies
      {
        'tonic-build' => %(tonic-build = { version = "0.4", features = ["prost"] }),
      }
    end
  end
end
