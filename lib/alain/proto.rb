# frozen_string_literal: true

module Alain #:nodoc:
  class Proto
    def initialize(service, package)
      @service = service
      @package = package
    end

    def rust_code
      puts "use tonic::{Request, Response, Status};"
      puts
      parse_import
      @service.each do |svc, methods|
        puts "pub struct #{svc}Service {}"
        puts
        puts "impl #{svc} for #{svc}Service {"
        methods.each do |method|
          puts "  async fn #{snake_case(method[:method])}(&self, request: Request<#{method[:request].gsub('.', '::')}>) -> Result<Response<#{method[:response].gsub('.', '::')}>, Status> {"
          puts "    let message = request.into_inner();"
          puts "    Ok(Response::new(#{method[:response].gsub('.', '::')} { }))"
          puts "  }"
          puts
        end
        puts "}"
      end
    end

    def parse_import
      package_ns = []
      other_ns = {}
      @service.each do |svc, methods|
        methods.each do |method|
          [:request, :response].each do |message_type|
            case method[message_type]
            when /^(.+)\.(\S+?)$/
              other_ns[$1] ||= []
              other_ns[$1] << $2
            else
              package_ns << method[message_type]
            end
          end
        end
      end
      mod_def [@package].concat(other_ns.keys)
      use_def package_ns, other_ns
    end

    # Tonic import macro
    #
    def mod_def(namespace)
      namespace.each do |ns|
        ns.split('.').each { |mod| puts "pub mod #{mod} {" }
        puts "  tonic::include_proto!(\"#{ns}\")"
        ns.split('.').each { |_mod| puts "}" }
        puts
      end
    end

    # use definition for shorthand
    #
    def use_def(package_ns, other_ns)
      puts "use #{namespace}::{"
      package_ns.uniq.each { |message| puts "  #{message}," }
      puts "}"
      puts
      other_ns.each do |ns, messages|
        puts "use #{ns.gsub('.', '::')}::{"
        messages.uniq.each { |message| puts "  #{message}," }
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
          when /^\s*rpc\s+(\S+)\s*\((\S+)\)\s+returns\s+\((\S+)\)\s*{/
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
