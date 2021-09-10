# frozen_string_literal: true

module Alain #:nodoc:
  module Util
    module_function

    def grpc_method method, request, response
      <<~EOS
        async fn #{snake_case(method)}(&self, request: Request<#{namespace(request)}>) -> Result<Response<#{namespace(response)}>, Status> {
                let message: #{namespace(request)} = request.into_inner();
                Ok(Response::new(#{namespace(response)} { }))
            }
      EOS
    end

    def namespace(ns = @package)
      ns.gsub('.', '::')
    end

    def snake_case(str)
      str.gsub(/([a-z\d])([A-Z])/, '\1_\2')
        .downcase
    end
  end
end
