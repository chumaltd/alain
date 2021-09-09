# frozen_string_literal: true
require 'erb'

module Alain #:nodoc:
  class Proto
    def initialize(service, package, proto_path)
      @proto_path = proto_path
      @service = service
      @package = package
      @svc_code = Pathname('src') / "#{service_name(:snake)}_service.rs"
      @implemented = method_scan
    end

    def update_svc
      origin = File.read @svc_code
      diff = method_diff
      File.open(@svc_code, 'w') do |f|
        origin.each_line do |line|
          if m = /^impl #{service_name}/.match(line)
            f.puts line
            f.puts diff
          else
            f.puts line
          end
        end
      end
    end

    def method_scan
      return [] unless svc_code_exist?

      [].tap do |res|
        File.open @svc_code  do |f|
          f.each_line do |line|
            if m = /async fn ([A-Za-z0-9_]+)\s*\(/.match(line)
              res << m[1]
            end
          end
        end
      end
    end

    # returns unimplemented methods
    #
    def method_diff
      [].tap do |res|
        @service.each do |svc, methods|
          methods.each do |method|
            next if @implemented.include? snake_case(method[:method])

            res << ''
            res << '  ' + grpc_method(method[:method], method[:request], method[:response]).gsub(/^}/, '  }')
          end
        end
      end.join("\n")
    end

    def svc_methods
      [].tap do |res|
        @service.each do |svc, methods|
          res << "pub struct #{svc}Service {}"
          res << ''
          res << '#[tonic::async_trait]'
          res << "impl #{svc} for #{svc}Service {"
          res << ''
          methods.each do |method|
            res << '  ' + grpc_method(method[:method], method[:request], method[:response]).gsub(/^}/, '  }')
          end
          res << "}"
        end
      end.join("\n")
    end

    def grpc_method method, request, response
      <<~EOS
        async fn #{snake_case(method)}(&self, request: Request<#{request.gsub('.', '::')}>) -> Result<Response<#{response.gsub('.', '::')}>, Status> {
            let message = request.into_inner();
            Ok(Response::new(#{response.gsub('.', '::')} { }))
        }
      EOS
    end

    def compile_protos
      <<~EOS
      tonic_build::compile_protos("#{@proto_path}")?;
      EOS
    end

    # Tonic import macro
    #
    def mod_def
      _, other_ns = parse_import
      namespaces = [@package].concat other_ns.keys
      [].tap do |res|
        namespaces.each do |namespace|
          ns = namespace.split('.')
          res << ns.map.with_index do |n, i|
            '  ' * i + "pub mod #{n} {"
          end
          res << '  ' * ns.length + %%tonic::include_proto!("#{@package}");%
          res << ns.map.with_index do |n, i|
            '  ' * (ns.length - i - 1) + '}'
          end
        end
      end.join("\n")
    end

    # use definition for shorthand
    #
    def use_def
      package_ns, other_ns = parse_import
      [].tap do |res|
        res << "use crate::#{namespace}::{"
        package_ns.uniq.each { |message| res << "  #{message}," }
        res << '};'
        res << ''
        other_ns.each do |ns, messages|
          res << "use crate::#{ns.gsub('.', '::')}::{"
          messages.uniq.each { |message| res << "  #{message}," }
          res << '};'
        end
      end.join("\n")
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
      [package_ns, other_ns]
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
      new(service, package, proto_path)
    end

    def namespace
      @package.gsub('.', '::')
    end

    def service_name(mode = :camel)
      case mode
      when :snake
        snake_case @service.keys.first
      else
        @service.keys.first
      end
    end

    def server_mod
      "#{namespace}::#{service_name :snake}_server::#{service_name}Server"
    end

    def svc_code_exist?
      File.exist? @svc_code
    end
  end
end
