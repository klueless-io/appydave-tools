# frozen_string_literal: true

require 'optparse'
require 'clipboard'
require 'fileutils'

require 'appydave/tools/version'
require 'appydave/tools/gpt_context/file_collector'

module Appydave
  module Tools
    # raise Appydave::Tools::Error, 'Sample message'
    Error = Class.new(StandardError)

    # Your code goes here...
  end
end

if ENV.fetch('KLUE_DEBUG', 'false').downcase == 'true'
  $LOADED_FEATURES.find { |f| f.include?('appydave/tools/version') }
  Appydave::Tools::VERSION.ljust(9)
  # puts "#{namespace.ljust(35)} : #{version.ljust(9)} : #{file_path}"
end
