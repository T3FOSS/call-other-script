#!/usr/local/rvm/rubies/ruby-2.1.0/bin/ruby
require "rack"
require "open-uri"
require_relative "properties"
require_relative "includer"

puts "content-type:text/html"
puts ""

params = Rack::Utils.parse_nested_query( ENV["QUERY_STRING"] )

GITHUB_URL = "https://raw.githubusercontent.com"
GITHUB_ORG = params["org"]
GITHUB_REPO = params["repo"]
GITHUB_SRCROOT = "src/main/lsl"
PROPERTIES_PATH = params["prop_path"]
GITHUB_PROPERTIES = "#{GITHUB_URL}/#{GITHUB_ORG}/#{GITHUB_REPO}/master/#{PROPERTIES_PATH}"

demo = Includer.new(
	GITHUB_URL,
	GITHUB_ORG,
	GITHUB_REPO,
	GITHUB_SRCROOT,
	PropertyConfigurer.new( GITHUB_PROPERTIES ) )

if params["file"].nil?
	exit
end

code_file = params["file"]

code_data = demo.process_file( code_file )

puts code_data
MORE STUFF
/**
Multiline comment
*/
STUFF
// singleline comment