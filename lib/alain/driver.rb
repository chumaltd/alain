# frozen_string_literal: true

require 'erb'
require 'fileutils'

module Alain #:nodoc:
  class Driver
    include Util
    attr_reader :cargo, :proto
    TMPL_DIR = Pathname(__dir__) / 'templates'

    def initialize(proto_file)
      @proto = Proto.parse(proto_file)
      @cargo = Cargo.new
      @package = @proto.package # required by namespace()
      @svc_code = SvcCode.new proto.service_name(:snake)
    end

    def generate(update_server = false, server_conf = false)
      @server_conf = server_conf
      if @svc_code.exist?
        STDERR.puts 'Already exists service definition. Only update methods...'
        update_svc
      else
        update_server = true
        STDERR.puts 'No service definition yet...'
        STDERR.puts 'Generate service definition'
        parse_svc
      end
      if update_server
        STDERR.puts 'Overwrite main.rs'
        parse_erb 'main.rs'
        STDERR.puts 'Overwrite lib.rs'
        parse_erb 'lib.rs'
        STDERR.puts 'Generate build.rs'
        parse_erb 'build.rs', '', '.'
        STDERR.puts 'Generate tests/common/mod.rs'
        FileUtils.mkdir_p 'tests/common/'
        parse_erb 'mod.rs', '', 'tests/common'
        STDERR.puts 'Generate tests/integration_test.rs'
        parse_erb 'integration_test.rs', '', 'tests'
        STDERR.puts 'Update Cargo.toml'
        cargo.add_dependencies(server_conf: @server_conf)
      end
      STDERR.puts 'Done'
    end

    private

    # patch unimplemented messages/methods
    # WARNING: This skips messages in a newly imported package.
    #
    def update_svc
      origin = File.read @svc_code.path
      messages = message_diff
      methods = method_diff
      File.open(@svc_code.path, 'w') do |f|
        origin.each_line do |line|
          if m = /^\s*use crate::([A-Za-z0-9_:]+)::{/.match(line)
            f.puts line
            f.puts '  ' + messages[namespace(m[1])].join(", ") + ',' unless messages[namespace(m[1])].empty?
          elsif m = /^impl #{proto.service_name}/.match(line)
            f.puts line
            f.puts methods if methods
          else
            f.puts line
          end
        end
      end
    end

    # returns unimplemented messages
    #
    def message_diff
      package_ns, other_ns = proto.parse_import
      {}.tap do |res|
        res[namespace] = package_ns.reject { |item| @svc_code.messages[namespace]&.include? item }
        other_ns.each do |ns, messages|
          res[namespace(ns)] = messages.reject { |item| @svc_code.messages[namespace(ns)]&.include? item }
        end
      end
    end

    # returns unimplemented methods
    #
    def method_diff
      [].tap do |res|
        proto.service.each do |svc, methods|
          methods.each do |method|
            next if method[:method].nil?
            next if @svc_code.methods.include? snake_case(method[:method])

            res << ''
            res << '  ' + grpc_method(method[:method], method[:request], method[:response]).gsub(/^}/, '  }')
          end
        end
        return nil if res.empty?
      end.join("\n")
    end

    def parse_svc
      parse_erb 'service.rs', "#{proto.service_name(:snake)}_"
    end

    def parse_erb(file_name, file_prefix = '', target_dir = 'src')
      erb = ERB.new(File.read(TMPL_DIR / "#{file_name}.erb"), trim_mode: '-')
      File.write(Pathname(target_dir) / "#{file_prefix}#{file_name}", erb.result(binding))
    end
  end
end
