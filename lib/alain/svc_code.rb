# frozen_string_literal: true
require 'erb'

module Alain #:nodoc:
  # parse generated service code
  #
  class SvcCode
    include Util
    attr_reader :messages, :methods, :path

    def initialize svc_name
      @path = Pathname('src') / "#{svc_name}_service.rs"
      @messages = message_scan
      @methods = method_scan
    end

    def exist?
      File.exist? @path
    end

    private

    # already implemented messages by service
    #
    def message_scan
      return [] unless exist?

      res = {}
      key = nil
      msg_blk= false
      File.foreach @path do |line|
        if m = /^\s*use crate::([A-Za-z0-9_:]+)::{/.match(line)
          key = m[1]
          msg_blk = true
        elsif msg_blk && /^\s*};/.match(line)
          msg_blk = false
        elsif msg_blk
          messages = line.split(',').map(&:strip).reject(&:empty?)
          res[key] ||= []
          res[key].concat messages
        end
      end
      res
    end

    # already implemented methods
    #
    def method_scan
      return [] unless exist?

      [].tap do |res|
        File.foreach @path  do |line|
          if m = /async fn ([A-Za-z0-9_]+)\s*\(/.match(line)
            res << m[1]
          end
        end
      end
    end
  end
end
