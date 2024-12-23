# frozen_string_literal: true

require 'tomlrb'

module Alain #:nodoc:
  attr_reader :cargo
  class Cargo
    def initialize(dir = '.')
      toml = Pathname(dir) / 'Cargo.toml'
      unless File.exist? toml
        STDERR.puts "./Cargo.toml not found. 'cargo init' first."
        exit 1
      end
      @cargo = Tomlrb.load_file toml
    end

    def add_dependencies(server_conf: false)
      toml = Pathname('.') / 'Cargo.toml'
      origin = File.read toml
      File.open(toml, 'w') do |f|
        origin.each_line do |line|
          if /^\[dependencies\]/.match(line)
            f.puts line
            dependencies(server_conf).each do |k, entry|
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

    def dependencies(server_conf)
      {
        'prost' => %(prost = "0.13"),
        'prost-types' => %(prost-types = "0.13"),
        'signal-hook' => %(signal-hook = "0.3.9"),
        'signal-hook-tokio' => %(signal-hook-tokio = { version = "0.3.0", features = ["futures-v0_3"] }),
        'tokio' => %(tokio = { version = "1.0", features = ["full"] }),
        'tokio-stream' => %(tokio-stream = "0.1.2"),
        'tonic' => %(tonic = "0.12"),
        'triggered' => %(triggered = "0.1.2")
      }.tap do |dep|
        if server_conf
          dep['server-conf'] = %(server-conf = { git = "https://github.com/chumaltd/server-util.git" })
        end
      end
    end

    def build_dependencies
      {
        'tonic-build' => %(tonic-build = { version = "0.12", features = ["prost"] }),
      }
    end
  end
end
