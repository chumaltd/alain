# frozen_string_literal: true

require_relative "alain/version"

module Alain
  autoload :Driver, 'alain/driver'
  autoload :Cargo, 'alain/cargo'
  autoload :Proto, 'alain/proto'
  autoload :SvcCode, 'alain/svc_code'
  autoload :Util, 'alain/util'
end
