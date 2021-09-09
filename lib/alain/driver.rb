# frozen_string_literal: true
require 'erb'

module Alain #:nodoc:
  class Driver
    attr_reader :cargo, :proto
    TMPL_DIR = Pathname(__dir__) / 'templates'

    def initialize(proto_file)
      unless File.exist? proto_file
        puts "#{proto_file} not found. Exit"
        exit 1
      end
      @cargo = Cargo.new
      @proto = Proto.parse(proto_file)
    end

    def generate(update_server = false)
      if proto.svc_code_exist?
        puts 'Already exists service definition. Only update methods...'
        proto.update_svc
      else
        update_server = true
        puts 'No service definition yet...'
        puts 'Generate service definition'
        parse_svc
      end
      if update_server
        puts 'Overwrite main.rs'
        parse_erb 'main.rs'
        puts 'Overwrite lib.rs'
        parse_erb 'lib.rs'
        puts 'Overwrite build.rs'
        parse_erb 'build.rs', '', '.'
        puts 'Update Cargo.toml'
        cargo.add_dependencies
      end
      puts 'Done'
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
