# frozen_string_literal: true

module Alain #:nodoc:
  class Proto
    def initialize(service, package)
      @service = service
      @package = package
    end

    # TODO: tonic proto macro
    def rust_code
      puts "use tonic::{Request, Response, Status};"
      puts
      use_def
      @service.each do |svc, methods|
        puts "pub struct #{svc}Service {}"
        puts
        puts "impl #{svc} for #{svc}Service {"
        methods.each do |method|
          puts "  async fn #{snake_case(method[:method])}(&self, request: Request<#{method[:request]}>) -> Result<Response<#{method[:response]}>, Status> {"
          puts "    let message = request.into_inner();"
          puts "    Ok(Response::new(#{method[:response]} { }))"
          puts "  }"
          puts
        end
        puts "}"
      end
    end

    # TODO: uniq duplicated messages
    def use_def
      @service.each do |svc, methods|
        puts "use #{namespace}::{"
        methods.each do |method|
          puts "  #{method[:request]}, #{method[:response]},"
        end
        puts "}"
        puts
      end
    end

    def snake_case(str)
      str.gsub(/([a-z\d])([A-Z])/, '\1_\2')
        .downcase
    end

    def self.parse(proto_path)
      package = nil
      service = {}
      current_svc = nil
      File.open(proto_path, 'r') do |f|
        f.each_line do |line|
          case line
          when /^\s*package\s+(\S+)\s*;/
            package = $1
          when /^\s*service\s+(\S+)\s*{/
            current_svc = $1
            service[current_svc] ||= []
          when /^\s*rpc\s+(\S+)\((\S+)\)\s+returns\s+\((\S+)\)\s*{/
            service[current_svc] << {
              method: $1,
              request: $2,
              response: $3
            }
          end
        end
      end
      new(service, package)
    end

    def namespace
      @package.gsub('.', '::')
    end
  end
end
