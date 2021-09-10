# frozen_string_literal: true

require 'erb'

module Alain #:nodoc:
  class Proto
    include Util
    attr_reader :package, :service
    INDENT = ' ' * 4

    def initialize(service, package, proto_path)
      unless File.exist? proto_path
        puts "#{proto_path} not found. Exit"
        exit 1
      end
      @path = proto_path
      @service = service
      @package = package
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
            next if method[:method].nil?

            res << INDENT + grpc_method(method[:method], method[:request], method[:response])
          end
          res << "}"
        end
      end.join("\n")
    end

    def compile_protos
      <<~EOS
      tonic_build::compile_protos("#{@path}")?;
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
            INDENT * i + "pub mod #{n} {"
          end
          res << INDENT * ns.length + %%tonic::include_proto!("#{@package}");%
          res << ns.map.with_index do |n, i|
            INDENT * (ns.length - i - 1) + '}'
          end
        end
      end.join("\n")
    end

    # use definition for shorthand
    #
    def use_def(crate = 'crate')
      package_ns, other_ns = parse_import
      [].tap do |res|
        res << "use #{crate}::#{namespace}::{"
        package_ns.uniq.each { |message| res << "#{INDENT}#{message}," }
        res << '};'
        res << ''
        other_ns.each do |ns, messages|
          res << "use crate::#{ns.gsub('.', '::')}::{"
          messages.uniq.each { |message| res << "#{INDENT}#{message}," }
          res << '};'
        end
      end.join("\n")
    end

    def self.parse(proto_path)
      package = nil
      service = {}
      current_svc = nil
      File.foreach(proto_path) do |line|
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
        when /^\s*message\s+(\S+)\s*{/
          # Filling nested messages
          service[current_svc] << {
            request: $1,
            method: nil, response: nil
          }
        end
      end
      new(service, package, proto_path)
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

    def parse_import
      package_ns = ["#{service_name(:snake)}_server::#{service_name}"]
      other_ns = {}
      @service.each do |svc, methods|
        methods.each do |method|
          [:request, :response].each do |message_type|
            next if method[message_type].nil?

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
      [package_ns.uniq, other_ns]
    end
  end
end
